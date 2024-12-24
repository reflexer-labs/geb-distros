DECLARE TokenAddress DEFAULT "0x6ba5b4e438fa0aaf7c1bd179285af65d13bd3d90";     -- ERC20 to incentivise
DECLARE DeployDate DEFAULT TIMESTAMP("2021-04-26 00:00:00+00");                -- UTC date, Set it to just before the first ever LP token mint
DECLARE StartDate DEFAULT TIMESTAMP("2024-09-15 12:50:00+00");                 -- UTC date, Set it to when to start to distribute rewards
DECLARE CutoffDate DEFAULT TIMESTAMP("2024-10-15 12:50:00+00");                -- UTC date, Set it to when to stop to distribute rewards
DECLARE TokenOffered DEFAULT 0e18;                                              -- Number of FLX to distribute in total

-- Constants
DECLARE NullAddress DEFAULT "0x0000000000000000000000000000000000000000";
DECLARE RewardRate DEFAULT TokenOffered / CAST(TIMESTAMP_DIFF(CutoffDate, StartDate, SECOND) AS BIGNUMERIC);


-- ==== Fetch & parse Compound events ===

-- Fetch the list of all token transfers (includes mint & burns)
WITH raw_erc20_transfers AS (
  SELECT * FROM `bigquery-public-data.crypto_ethereum.token_transfers`
  WHERE block_timestamp >= DeployDate 
    AND block_timestamp <= CutoffDate
    AND token_address = TokenAddress
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

-- Add erc20 token total_supply and individual balances
erc20_transfers_balance_all AS (
  SELECT 
    block_timestamp,
    log_index,
    address,
    delta_lp,
    -- Add total_supply of lp token by looking at the balance of 0x0
    SUM(CASE WHEN address = NullAddress THEN -1 * delta_lp ELSE 0 END) OVER(ORDER BY block_timestamp, log_index) AS total_supply,
    -- LP balance of each individual address
    SUM(delta_lp) OVER(PARTITION BY address ORDER BY block_timestamp, log_index) AS balance
  FROM erc20_transfers_deltas
),

erc20_transfers_balance AS (
SELECT * FROM erc20_transfers_balance_all
),

-- ==== Add initial & final state events ====

-- 1) Initial state
initial_state_event AS (
SELECT total_supply FROM erc20_transfers_balance WHERE block_timestamp <= StartDate ORDER BY block_timestamp DESC LIMIT 1
),

erc20_initial_state AS (
  SELECT  
    StartDate AS block_timestamp, 
    -1 AS log_index, 
    address, 
    SUM(delta_lp) AS balance,
    (SELECT total_supply FROM initial_state_event) AS total_supply,
  FROM erc20_transfers_balance
  WHERE block_timestamp <= StartDate
  GROUP BY address
),

-- 2) Final state
final_state_event AS (
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
    (SELECT total_supply FROM final_state_event) AS total_supply,
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
final_reward_list AS (
  SELECT address, SUM(earned) AS reward
  FROM erc20_earned
  GROUP BY address
),


filtered_reward_list AS (
  SELECT address, reward 
  FROM final_reward_list
  WHERE address != NullAddress AND address != "0x66ec719045bbd62db5ebb11184c18237d3cc2e62"
),

normalized_reward_list AS (
  SELECT address, reward * TokenOffered / (SELECT SUM(reward) FROM filtered_reward_list) AS reward, TokenOffered / (SELECT SUM(reward) FROM filtered_reward_list) AS a, (SELECT SUM(reward) FROM filtered_reward_list) AS b
  FROM filtered_reward_list
)

-- Output results
SELECT address, CAST(reward AS NUMERIC)/1e18 AS reward
FROM normalized_reward_list 
WHERE 
  address != NullAddress AND
  reward > 0
ORDER BY reward DESC
