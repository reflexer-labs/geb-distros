-- Config 
DECLARE StartDate DEFAULT TIMESTAMP("2022-02-15 12:50:00+00"); -- UTC date, Set it to when to start to distribute rewards
DECLARE CutoffDate DEFAULT TIMESTAMP("2022-03-15 12:50:00+00"); -- UTC date, Set it to when to stop to distribute rewards
DECLARE BorrowAsset DEFAULT "0x03ab458634910aad20ef5f1c8ee96f1d6ac54919"; -- Asset to reward borrowers RAI 0x03ab458634910aad20ef5f1c8ee96f1d6ac54919 USDC 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
DECLARE TokenOffered DEFAULT 280e18; -- Number of FLX to distribute in total

-- Constants
DECLARE RewardRate DEFAULT TokenOffered / CAST(TIMESTAMP_DIFF(CutoffDate, StartDate, SECOND) AS BIGNUMERIC); -- FLX dsitributed per second

-- Get all events needed
WITH borrow_events AS (
  SELECT block_timestamp, log_index, onBehalfOf AS address, CAST(amount AS BIGNUMERIC) / 1e18 AS delta_balance
  FROM `blockchain-etl.ethereum_aave.LendingPool_v2_event_Borrow` 
  WHERE reserve = BorrowAsset AND borrowRateMode = "2" AND block_timestamp < CutoffDate
),

repay_events AS (
  SELECT block_timestamp , log_index, user AS address, -1 * CAST(amount as BIGNUMERIC) / 1e18 AS delta_balance
  FROM `blockchain-etl.ethereum_aave.LendingPool_v2_event_Repay` 
  WHERE reserve = BorrowAsset AND block_timestamp < CutoffDate
),

accrue_interest_event AS (
SELECT block_timestamp, CAST(variableBorrowIndex AS BIGNUMERIC) / 1e27 as index
FROM `blockchain-etl.ethereum_aave.LendingPool_v2_event_ReserveDataUpdated`
WHERE reserve = BorrowAsset AND block_timestamp < CutoffDate
),

-- Union borrows and repays
borrows_and_repays AS (
  SELECT * FROM borrow_events
  UNION ALL
  SELECT * FROM repay_events
),

-- Join the borrow index to each event
aave_with_borrow_index AS (
SELECT DISTINCT
    borrows_and_repays.block_timestamp AS block_timestamp,
    borrows_and_repays.log_index AS log_index,
    borrows_and_repays.address AS address,
    borrows_and_repays.delta_balance AS delta_balance,
    accrue_interest_event.index AS borrow_index
FROM borrows_and_repays INNER JOIN accrue_interest_event ON borrows_and_repays.block_timestamp=accrue_interest_event.block_timestamp
),

aave_events as (
  SELECT *,
    SUM(delta_balance) OVER(ORDER BY block_timestamp, log_index) AS total_supply,
    SUM(delta_balance) OVER(PARTITION BY address ORDER BY block_timestamp, log_index) AS balance,
    (SUM(delta_balance) OVER(ORDER BY block_timestamp, log_index)) / borrow_index  AS scaled_total_supply,
    (SUM(delta_balance) OVER(PARTITION BY address ORDER BY block_timestamp, log_index)) / borrow_index AS scaled_balance,
  FROM aave_with_borrow_index
),

-- -- ==== Add initial & final state events ====

-- Note: Since the `accrueIntrest` function likley wasn't called  in the block of StartDate and
-- CutOffDate we consider the latest intrest accrual before startDate and CutOff date for the 
-- intrest accrual of everyone. This create a small inaccuracy were we will underdistribute
-- for accrued intrest of everyone between the latest intrest accrual and and the Start/End date.

-- 1) Prepare Initial states

-- Keep only records before the start date
events_before_start AS (
  SELECT * FROM aave_events
  WHERE block_timestamp < StartDate
),

-- The latest event just before the start date
initial_state_event AS (
SELECT total_supply, borrow_index FROM events_before_start ORDER BY block_timestamp DESC LIMIT 1
),

initial_balances as (
  SELECT *   
  FROM  (
    -- Pick the most recent event for each address 
    SELECT 
      address,
      -- To account for the accrued interest, the last borrow balance is augmented with the accrued 
      -- interest according the index formula: 
      -- balance_with_accrued_interest = principal * current_idnex / index_since_last_accrued
      scaled_balance * (SELECT borrow_index FROM initial_state_event) AS balance,
      -- Add a rank within each address by descending time order
      -- Rank 1 means the most recent event for a given address
      RANK() OVER (PARTITION BY address ORDER BY block_timestamp DESC, log_index DESC) as rank 
    FROM events_before_start
   ) 
  WHERE rank=1
  GROUP BY address, balance, rank
),

-- Initial state on the start date (balance on the start date)
aave_initial_state AS (
  SELECT 
    StartDate AS block_timestamp,
    -- Set it to -1 to be sure it comes before everything else in the start block
    -1 AS log_index,
    address,
    balance AS balance,
    -- Take latest total supply
    (SELECT total_supply FROM initial_state_event) AS total_supply,
    -- Delta_balance is the full balance at start
    balance AS delta_balance
  FROM initial_balances
),

-- 2) Prepare final states

-- The latest event just before the cutoff date
final_state_event AS (
SELECT total_supply, borrow_index FROM aave_events ORDER BY block_timestamp DESC LIMIT 1
),

-- Final balances on the cutoff date
final_balance as (
  SELECT *
  FROM  (
    -- Pick the most recent event for each address 
    SELECT
      address,
      -- To account for the accrued interest, the last borrow balance is augmented with the accrued 
      -- interest according the index formula: 
      -- balance_with_accrued_interest = principal * current_idnex / index_since_last_accrued
      scaled_balance * (SELECT borrow_index FROM final_state_event) AS balance,
      -- Add a rank within each address by descending time order
      -- Rank 1 means the most recent event for a given address
      RANK() OVER (PARTITION BY address ORDER BY block_timestamp DESC, log_index DESC) as rank 
    FROM aave_events
   ) 
  WHERE rank=1
  GROUP BY address, balance, rank
),

-- Final state on cutoff date
aave_final_states AS (
  SELECT
    CutoffDate AS block_timestamp,
    -- Set it to the highest log index to be sure it comes last
    (SELECT MAX(log_index) FROM aave_events) AS log_index,
    address AS address,
    balance,
    -- Final total_supply
    (SELECT total_supply FROM final_state_event) AS total_supply,
    0 as delta_balance
  FROM final_balance
),

-- 3) Union everything 
with_start_events AS (
  SELECT block_timestamp, log_index, address, balance, total_supply, delta_balance
    FROM aave_events
    WHERE block_timestamp >= StartDate
  
  UNION ALL
  SELECT * FROM aave_initial_state
  
  UNION ALL 
  SELECT * FROM aave_final_states

),


-- ==== Reward calculation ====

-- Note: This script does not reward for the exact borrow balance.
-- Due to the constantly accruing borrow balance we only consider
-- the borrow balance at the time of the event thus overdistributing 
-- a bit. We distribute like if the accured part was constant since the
-- last crediting.

-- 1) Calculate the cumulative reward per token 

-- Add the delta_reward_per_token (increase in reward_per_token)
aave_deltas AS (
  SELECT *, 
      COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS BIGNUMERIC), 0) AS delta_t,
      IF(total_supply - delta_balance = 0, 0,
        COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS BIGNUMERIC), 0) * RewardRate / (total_supply - delta_balance)
      ) AS delta_reward_per_token
      
  FROM with_start_events),

-- Calculated the actual reward_per_token from the culmulative delta
aave_reward_per_token AS (
  SELECT *,
    SUM(delta_reward_per_token) OVER(ORDER BY block_timestamp, log_index) AS reward_per_token
  FROM aave_deltas
),

-- 2) Credit reward for each user at each event

-- basically the earned() function from a staking contract
aave_earned AS (
  SELECT *,
    --                       ⬇ userRewardPerTokenPaid                                                                             ⬇ balance just before 
    (reward_per_token - COALESCE(LAG(reward_per_token,1) OVER(PARTITION BY address ORDER BY block_timestamp, log_index), 0)) * COALESCE(balance - delta_balance, 0) AS earned,
  FROM aave_reward_per_token
),


-- ==== Output results ====

-- Sum up the earned event per address
final_reward_list AS (
  SELECT address, SUM( CASE WHEN earned < 0 THEN 0 ELSE earned END) AS reward
  FROM aave_earned
  GROUP BY address
),

-- Normalize result to distribute the exact amount of token
-- This is needed to address the inaccuracies stated above
final_normalized_reward_list AS (
  SELECT address, reward * TokenOffered / (SELECT SUM(reward) FROM final_reward_list) AS reward 
  FROM final_reward_list
)

-- Output results
SELECT address, reward/1e18 AS reward
FROM final_normalized_reward_list 
ORDER BY reward DESC