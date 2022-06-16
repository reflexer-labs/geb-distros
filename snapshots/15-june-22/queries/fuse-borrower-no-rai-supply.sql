-- Config 
DECLARE DeployDate DEFAULT TIMESTAMP("2021-04-8 20:00:00+00"); -- UTC date, Set it to just before the first ever LP token mint
DECLARE StartDate DEFAULT TIMESTAMP("2022-05-15 12:50:00+00"); -- UTC date, Set it to when to start to distribute rewards
DECLARE CutoffDate DEFAULT TIMESTAMP("2022-06-15 12:50:00+00"); -- UTC date, Set it to when to stop to distribute rewards
DECLARE CTokenAddress DEFAULT "0x752f119bd4ee2342ce35e2351648d21962c7cafe"; -- CToken contract
DECLARE TokenOffered DEFAULT 310e18; -- Number of FLX to distribute in total

-- Constants
DECLARE NullAddress DEFAULT "0x752f119bd4ee2342ce35e2351648d21962c7cafe";
DECLARE RewardRate DEFAULT TokenOffered / CAST(TIMESTAMP_DIFF(CutoffDate, StartDate, SECOND) AS BIGNUMERIC); -- FLX dsitributed per second
DECLARE BorrowTopic DEFAULT "0x13ed6866d4e1ee6da46f845c46d7e54120883d75c5ea9a2dacc1c4ca8984ab80"; -- Borrow event topic0
DECLARE RepayBorrowTopic DEFAULT "0x1a2a22cb034d26d1854bdc6666a5b91fe25efbbb5dcad3b0355478d6f5c362a1"; -- Repay event topic0
DECLARE AccrueInterestTopic DEFAULT "0x4dec04e750ca11537cabcd8a9eab06494de08da3735bc8871cd41250e190bc04"; -- Accrue intrest event topic0

-- Borrow event parse function
CREATE TEMP FUNCTION
  PARSE_BORROW_EVENT(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`borrower` STRING, `accountBorrows` STRING, `totalBorrows` STRING, `borrowAmount` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous": false,"inputs": [{"indexed": false,"internalType": "address","name": "borrower","type": "address"},{"indexed": false,"internalType": "uint256","name": "borrowAmount","type": "uint256"},{"indexed": false,"internalType": "uint256","name": "accountBorrows","type": "uint256"},{"indexed": false,"internalType": "uint256","name": "totalBorrows","type": "uint256"}],"name": "Borrow","type": "event"};
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

-- Repay event parse function
CREATE TEMP FUNCTION
  PARSE_REPAY_BORROW_EVENT(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`borrower` STRING, `accountBorrows` STRING, `totalBorrows` STRING, `repayAmount` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous": false,"inputs": [{"indexed": false,"internalType": "address","name": "payer","type": "address"},{"indexed": false,"internalType": "address","name": "borrower","type": "address"},{"indexed": false,"internalType": "uint256","name": "repayAmount","type": "uint256"},{"indexed": false,"internalType": "uint256","name": "accountBorrows","type": "uint256"},{"indexed": false,"internalType": "uint256","name": "totalBorrows","type": "uint256"}],"name": "RepayBorrow","type": "event"};
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

-- AccrueIntrest event parse function
CREATE TEMP FUNCTION
  PARSE_ACCRUE_INTEREST_EVENT(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`borrowIndex` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"cashPrior","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"interestAccumulated","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"borrowIndex","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"totalBorrows","type":"uint256"}],"name":"AccrueInterest","type":"event"};
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

-- ==== Fetch & parse Compound events ===

-- Get all borrow and repay borrow events for a CToken contract
WITH ctoken_raw_events AS (
  SELECT data, topics, block_number, block_timestamp, log_index FROM `bigquery-public-data.crypto_ethereum.logs`
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

accrue_interest_parse_event AS (
SELECT block_number, CAST(params.borrowIndex AS BIGNUMERIC) / 1e18 AS borrow_index
FROM accrue_interest_event
),

-- Union borrows and repays
borrows_and_repays AS (
  SELECT 
    block_timestamp,
    block_number,
    log_index, 
    params.borrower AS address, 
    CAST(params.accountBorrows AS BIGNUMERIC) AS balance, 
    CAST(params.totalBorrows AS BIGNUMERIC) AS total_supply,
    CAST(params.borrowAmount AS BIGNUMERIC) AS delta_balance,
  FROM borrow_event
  
  UNION ALL
  
  SELECT 
    block_timestamp,
    block_number,
    log_index, 
    params.borrower AS address, 
    CAST(params.accountBorrows AS BIGNUMERIC) AS balance, 
    CAST(params.totalBorrows AS BIGNUMERIC) AS total_supply,
    -1 * CAST(params.repayAmount AS BIGNUMERIC) AS delta_balance,
  FROM repay_borrow_event
),

-- Join the borrow index to each event
ctoken_parsed_events as (
SELECT
  borrows_and_repays.block_timestamp AS block_timestamp,
  borrows_and_repays.log_index AS log_index,
  borrows_and_repays.address AS address,
  borrows_and_repays.balance AS balance,
  borrows_and_repays.total_supply AS total_supply,
  borrows_and_repays.delta_balance AS delta_balance,
  accrue_interest_parse_event.borrow_index AS borrow_index
FROM borrows_and_repays LEFT JOIN accrue_interest_parse_event ON borrows_and_repays.block_number=accrue_interest_parse_event.block_number
),

-- ==== Add initial & final state events ====

-- Note: Since the `accrueIntrest` function likley wasn't called  in the block of StartDate and
-- CutOffDate we consider the latest intrest accrual before startDate and CutOff date for the 
-- intrest accrual of everyone. This create a small inaccuracy were we will underdistribute
-- for accrued intrest of everyone between the latest intrest accrual and and the Start/End date.

-- 1) Prepare Initial states

-- Keep only records before the start date
ctoken_events_before_start AS (
  SELECT * FROM ctoken_parsed_events
  WHERE block_timestamp < StartDate
),

-- The latest event just before the start date
initial_state_event AS (
SELECT total_supply, borrow_index FROM ctoken_events_before_start ORDER BY block_timestamp DESC LIMIT 1
),

-- Calculate the initial balance on start date for each address
initial_balances as (
  SELECT *   
  FROM  (
    -- Pick the most recent event for each address 
    SELECT 
      address,
      -- To account for the accrued interest, the last borrow balance is augmented with the accrued 
      -- interest according the index formula: 
      -- balance_with_accrued_interest = principal * current_idnex / index_since_last_accrued
      balance * (SELECT borrow_index FROM initial_state_event) / borrow_index AS balance,
      -- Add a rank within each address by descending time order
      -- Rank 1 means the most recent event for a given address
      RANK() OVER (PARTITION BY address ORDER BY block_timestamp DESC, log_index DESC) as rank 
    FROM ctoken_events_before_start
   ) 
  WHERE rank=1
),

-- Initial state on the start date (balance on the start date)
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

-- 2) Prepare final states

-- The latest event just before the cutoff date
final_state_event AS (
SELECT total_supply, borrow_index FROM ctoken_parsed_events ORDER BY block_timestamp DESC LIMIT 1
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
      balance * (SELECT borrow_index FROM final_state_event) / borrow_index AS balance,
      -- Add a rank within each address by descending time order
      -- Rank 1 means the most recent event for a given address
      RANK() OVER (PARTITION BY address ORDER BY block_timestamp DESC, log_index DESC) as rank 
    FROM ctoken_parsed_events
   ) 
  WHERE rank=1
),

-- Final state on cutoff date
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


-- ==== Reward calculation ====

-- Note: This script does not reward for the exact borrow balance.
-- Due to the constantly accruing borrow balance we only consider
-- the borrow balance at the time of the event thus overdistributing 
-- a bit. We distribute like if the accured part was constant since the
-- last crediting.

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
  SELECT address, SUM(earned) / 1e18 AS reward
  FROM ctoken_earned
  GROUP BY address
),

-- Normalize result to distribute the exact amount of token
-- This is needed to address the inaccuracies stated above
# final_normalized_reward_list AS (
#   SELECT address, reward * TokenOffered / (SELECT tot FROM final_reward_list_tot) AS reward 
#   FROM final_reward_list
#     WHERE reward > 0
# ),

-- =================== TRACK SUPPLY ===================

raw_erc20_transfers AS (
  SELECT * FROM `bigquery-public-data.crypto_ethereum.token_transfers`
  WHERE block_timestamp >= DeployDate 
    AND block_timestamp <= CutoffDate
    AND token_address = CTokenAddress
    -- Parasite transaction
    AND (from_address != NullAddress OR to_address != NullAddress)
), 


-- Calculate the realtive LP token balance delta, outgoing transfer is negative delta
erc20_transfers_deltas AS (
  SELECT * FROM (
    SELECT block_timestamp, block_number, log_index, from_address AS address, -1 * CAST(value AS BIGNUMERIC) AS delta_lp FROM raw_erc20_transfers
    UNION ALL 
    SELECT block_timestamp, block_number, log_index, to_address AS address, CAST(value AS BIGNUMERIC) AS delta_lp FROM raw_erc20_transfers
  )
),

-- Exclusion list of addresses that wont receive rewards
excluded_list AS (
  SELECT address FROM `reflexer-bigquery-analytics.exclusions.excluded_owners`),

-- Add erc20 token total_supply and individual balances
erc20_transfers_balance_all AS (
  SELECT 
    block_timestamp,
    log_index,
    address,
    delta_lp,
    -- Add total_supply of lp token by looking at the balance of 0x0
    SUM(CASE WHEN (address = NullAddress OR address IN (SELECT address FROM excluded_list)) THEN -1 * delta_lp ELSE 0 END) OVER(ORDER BY block_timestamp, log_index) AS total_supply,
    -- LP balance of each individual address
    SUM(delta_lp) OVER(PARTITION BY address ORDER BY block_timestamp, log_index) AS balance
  FROM erc20_transfers_deltas
),

erc20_transfers_balance AS (
SELECT * FROM erc20_transfers_balance_all
WHERE address NOT IN (SELECT address FROM excluded_list)
),

-- ==== Add initial & final state events ====

-- 1) Initial state
erc_20_initial_state_event AS (
SELECT total_supply FROM erc20_transfers_balance WHERE block_timestamp <= StartDate ORDER BY block_timestamp DESC LIMIT 1
),

erc20_initial_state AS (
  SELECT  
    StartDate AS block_timestamp, 
    -1 AS log_index, 
    address, 
    SUM(delta_lp) AS balance,
    (SELECT total_supply FROM erc_20_initial_state_event) AS total_supply,
  FROM erc20_transfers_balance
  WHERE block_timestamp <= StartDate
  GROUP BY address
),

-- 2) Final state
erc20_final_state_event AS (
SELECT total_supply FROM erc20_transfers_balance ORDER BY block_timestamp DESC LIMIT 1
),

erc20_final_states AS (
  SELECT
    CutoffDate AS block_timestamp,
    -- Set it to the highest log index to be sure it comes last
    (SELECT MAX(log_index) FROM erc20_transfers_balance) AS log_index,
    address,
    -- Final balance
    SUM(delta_lp) AS balance,
    -- Final total_supply
    (SELECT total_supply FROM erc20_final_state_event) AS total_supply,
  FROM erc20_transfers_balance
  GROUP BY address
),

-- 3) Union everything

-- Merge records from before and after
erc20_campaign AS (
  SELECT block_timestamp, log_index, address, balance, total_supply 
    FROM erc20_transfers_balance 
    WHERE block_timestamp >= StartDate

  UNION ALL 
  SELECT block_timestamp, log_index, address, balance, total_supply FROM erc20_initial_state

  UNION ALL

  SELECT block_timestamp, log_index, address, balance, total_supply FROM erc20_final_states
),

-- ==== Reward calculation ====

-- Add the delta_reward_per_token (increase in reward_per_token)
erc20_campaign_delta_reward_per_token AS (
  SELECT *, 
      COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS BIGNUMERIC), 0) AS delta_t,
      COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS BIGNUMERIC), 0) * RewardRate / (LAG(total_supply) OVER(ORDER BY block_timestamp, log_index)) AS delta_reward_per_token

  FROM erc20_campaign),

-- Calculated the actual reward_per_token from the culmulative delta
erc20_reward_per_token AS (
  SELECT *,
    SUM(delta_reward_per_token) OVER(ORDER BY block_timestamp, log_index) AS reward_per_token
  FROM erc20_campaign_delta_reward_per_token
),

-- Credit rewards, basically the earned() function from a staking contract
erc20_earned AS (
  SELECT *,
    --                       ⬇ userRewardPerTokenPaid                                                                             ⬇ balance just before 
    (reward_per_token - COALESCE(LAG(reward_per_token,1) OVER(PARTITION BY address ORDER BY block_timestamp, log_index), 0)) * COALESCE(LAG(balance) OVER(PARTITION BY address ORDER BY block_timestamp, log_index),0) AS earned,
  FROM erc20_reward_per_token
),

-- Sum up the earned event per address
erc20_final_reward_list AS (
  SELECT address, SUM(earned)/1e18 AS reward
  FROM erc20_earned
  WHERE 
    address != NullAddress AND
    earned > 0
  GROUP BY address
),


no_lender_reward_list AS (
  SELECT
    a.address AS address,
    GREATEST(a.reward - COALESCE(b.reward, 0),0) as reward,
    a.reward as a,
    b.reward as b 
  FROM final_reward_list a
  LEFT JOIN erc20_final_reward_list b
  ON a.address = b.address
),

total_rewards as (
  SELECT SUM(reward) as tot FROM no_lender_reward_list
)

SELECT address, reward * (TokenOffered / 1e18) / (SELECT tot FROM total_rewards)as reward
FROM no_lender_reward_list
ORDER BY reward DESC