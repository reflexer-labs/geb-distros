-- Config 
DECLARE DeployDate DEFAULT TIMESTAMP("2021-05-08 16:00:00+00"); -- UTC date, Set it to just before the first ever LP token mint
DECLARE StartDate DEFAULT TIMESTAMP("2021-06-17 12:50:00+00"); -- UTC date, Set it to when to start to distribute rewards
DECLARE CutoffDate DEFAULT TIMESTAMP("2021-07-15 12:50:00+00"); -- UTC date, Set it to when to stop to distribute rewards
DECLARE CTokenAddress DEFAULT "0xa7c3304462b169c71f8edc894ea9d32879fb4823"; -- Kashi RAI/DAI
DECLARE TokenOffered DEFAULT 280e18; -- Number of FLX to distribute in total

-- Constants
DECLARE RewardRate DEFAULT TokenOffered / CAST(TIMESTAMP_DIFF(CutoffDate, StartDate, SECOND) AS BIGNUMERIC); -- FLX dsitributed per second
DECLARE BorrowTopic DEFAULT "0x3a5151e57d3bc9798e7853034ac52293d1a0e12a2b44725e75b03b21f86477a6"; -- Borrow event topic0
DECLARE RepayBorrowTopic DEFAULT "0xc8e512d8f188ca059984b5853d2bf653da902696b8512785b182b2c813789a6e"; -- Repay event topic0 Repay tx eg 0xcafeea8163a7be20b2d3f631bcfb6c1190c35d21efd3e08fa4d47f7fba2239d1
DECLARE AccrueInterestTopic DEFAULT "0x33af5ce86e8438eff54589f85332916444457dfa8685493fbd579b809097026b"; -- Accrue intrest event topic0

-- Borrow event parse function
CREATE TEMP FUNCTION
  PARSE_BORROW_EVENT(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`from` STRING, `to` STRING, `amount` STRING, `feeAmount` STRING, `part` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"feeAmount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"part","type":"uint256"}],"name":"LogBorrow","type":"event"};
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

-- Repay event parse function
CREATE TEMP FUNCTION
  PARSE_REPAY_BORROW_EVENT(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`from` STRING, `to` STRING, `amount` STRING, `part` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"part","type":"uint256"}],"name":"LogRepay","type":"event"};
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

-- AccrueIntrest event parse function
CREATE TEMP FUNCTION
  PARSE_ACCRUE_INTEREST_EVENT(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`accruedAmount` STRING, `feeFraction` STRING, `rate` STRING, `utilization` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"accruedAmount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"feeFraction","type":"uint256"},{"indexed":false,"internalType":"uint64","name":"rate","type":"uint64"},{"indexed":false,"internalType":"uint256","name":"utilization","type":"uint256"}],"name":"LogAccrue","type":"event"};
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

-- ==== Fetch & parse Compound events ===

-- Get all borrow and repay borrow events for a CToken contract
WITH ctoken_raw_events AS (
  SELECT data, topics, block_number, block_timestamp, log_index, transaction_hash FROM `bigquery-public-data.crypto_ethereum.logs`
    WHERE block_timestamp >= DeployDate
      AND block_timestamp <= CutoffDate
      AND address = CTokenAddress
      AND (topics[offset(0)] = BorrowTopic OR topics[offset(0)] = RepayBorrowTopic OR topics[offset(0)] = AccrueInterestTopic)
),

-- Parse the borrows
borrow_event AS (
  SELECT *, PARSE_BORROW_EVENT(data, topics) as params 
  FROM ctoken_raw_events 
  WHERE topics[offset(0)] = BorrowTopic
),

-- Parse the repays 
repay_borrow_event AS (
  SELECT *, PARSE_REPAY_BORROW_EVENT(data, topics) as params 
  FROM ctoken_raw_events 
  WHERE topics[offset(0)] = RepayBorrowTopic
),

-- Parse accrue interest
accrue_interest_event AS (
  SELECT *, PARSE_ACCRUE_INTEREST_EVENT(data, topics) as params 
  FROM ctoken_raw_events 
  WHERE topics[offset(0)] = AccrueInterestTopic
),

-- Union borrows and repays
borrows_and_repays AS (
  SELECT 
    block_timestamp,
    block_number,
    log_index,
    params.from AS address, 
    CAST(params.part AS BIGNUMERIC) AS delta_balance,
    transaction_hash,
  FROM borrow_event
  
  UNION ALL
  
  SELECT 
    block_timestamp,
    block_number,
    log_index, 
    params.to AS address, 
    -1 * CAST(params.part AS BIGNUMERIC) AS delta_balance,
    transaction_hash
  FROM repay_borrow_event
),

excluded_list AS (
  SELECT address FROM `reflexer-bigquery-analytics.exclusions.excluded_owners`),
  
ctoken_parsed_events AS (
SELECT *, 
  SUM(delta_balance) OVER (ORDER BY block_timestamp, log_index ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_supply,
  SUM(delta_balance) OVER (PARTITION BY address ORDER BY block_timestamp, log_index ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance,
FROM borrows_and_repays 
WHERE address NOT IN (SELECT address FROM excluded_list)

),

-- -- ==== Add initial & final state events ====

-- -- Note: Since the `accrueIntrest` function likley wasn't called  in the block of StartDate and
-- -- CutOffDate we consider the latest intrest accrual before startDate and CutOff date for the 
-- -- intrest accrual of everyone. This create a small inaccuracy were we will underdistribute
-- -- for accrued intrest of everyone between the latest intrest accrual and and the Start/End date.

-- -- 1) Prepare Initial states

-- -- Keep only records before the start date
ctoken_events_before_start AS (
  SELECT * FROM ctoken_parsed_events
  WHERE block_timestamp < StartDate
),

-- The latest event just before the start date
initial_state_event AS (
SELECT total_supply FROM ctoken_events_before_start ORDER BY block_timestamp DESC LIMIT 1
),

-- -- Calculate the initial balance on start date for each address
initial_balances as (
  SELECT *   
  FROM  (
    -- Pick the most recent event for each address 
    SELECT 
      address,
      balance AS balance,
      -- Add a rank within each address by descending time order
      -- Rank 1 means the most recent event for a given address
      RANK() OVER (PARTITION BY address ORDER BY block_timestamp DESC, log_index DESC) as rank 
    FROM ctoken_events_before_start
   ) 
  WHERE rank=1
),

-- -- Initial state on the start date (balance on the start date)
ctoken_initial_state AS (
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

-- -- 2) Prepare final states

-- The latest event just before the cutoff date
final_state_event AS (
SELECT total_supply FROM ctoken_parsed_events ORDER BY block_timestamp DESC LIMIT 1
),

-- -- Final balances on the cutoff date
final_balance as (
  SELECT *
  FROM  (
    -- Pick the most recent event for each address 
    SELECT
      address,
      balance AS balance,
      -- Add a rank within each address by descending time order
      -- Rank 1 means the most recent event for a given address
      RANK() OVER (PARTITION BY address ORDER BY block_timestamp DESC, log_index DESC) as rank 
    FROM ctoken_parsed_events
   ) 
  WHERE rank=1
),

-- -- Final state on cutoff date
ctoken_final_states AS (
  SELECT
    CutoffDate AS block_timestamp,
    -- Set it to the highest log index to be sure it comes last
    (SELECT MAX(log_index) FROM ctoken_parsed_events) AS log_index,
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
    FROM ctoken_parsed_events
    WHERE block_timestamp >= StartDate
  
  UNION ALL
  SELECT * FROM ctoken_initial_state
  
  UNION ALL 
  SELECT * FROM ctoken_final_states

),

-- -- ==== Reward calculation ====

-- Note: This script does not reward for the exact borrow balance
-- because of the constantly accruing borrow balance. We consider
-- the principal

-- 1) Calculate the cumulative reward per token 

-- Add the delta_reward_per_token (increase in reward_per_token)
ctoken_deltas AS (
  SELECT *, 
      COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS BIGNUMERIC), 0) AS delta_t,
      IF(total_supply - delta_balance = 0, 0,
        COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS BIGNUMERIC), 0) * RewardRate / (total_supply - delta_balance)
      ) AS delta_reward_per_token
      
  FROM with_start_events),

-- Calculated the actual reward_per_token from the culmulative delta
ctoken_reward_per_token AS (
  SELECT *,
    SUM(delta_reward_per_token) OVER(ORDER BY block_timestamp, log_index) AS reward_per_token
  FROM ctoken_deltas
),

-- 2) Credit reward for each user at each event

-- basically the earned() function from a staking contract
ctoken_earned AS (
  SELECT *,
    --                       ⬇ userRewardPerTokenPaid                                                                             ⬇ balance just before 
    (reward_per_token - COALESCE(LAG(reward_per_token,1) OVER(PARTITION BY address ORDER BY block_timestamp, log_index), 0)) * COALESCE(balance - delta_balance, 0) AS earned,
  FROM ctoken_reward_per_token
),


-- ==== Output results ====

-- Sum up the earned event per address
final_reward_list AS (
  SELECT address, SUM(earned) AS reward
  FROM ctoken_earned
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