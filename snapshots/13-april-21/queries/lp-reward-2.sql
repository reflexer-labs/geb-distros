# Config 
DECLARE LPTokenAddress DEFAULT "0x8ae720a71622e824f576b4a8c03031066548a3b1";   # UNI-V2-ETH/RAI address, lower case only
DECLARE DeployDate DEFAULT TIMESTAMP("2021-02-13 12:33:18+00");                # UTC date, Set it to just before the first ever LP token mint
DECLARE StartDate DEFAULT TIMESTAMP("2021-02-20 22:25:00+00");                 # UTC date, Set it to when to start to distribute rewards
DECLARE CutoffDate DEFAULT TIMESTAMP("2021-02-26 13:50:00+00");                # UTC date, Set it to when to stop to distribute rewards
DECLARE TokenOffered DEFAULT 1884.548611111111e18;                             # Number of FLX to distribute in total

# Constants
DECLARE NullAddress DEFAULT "0x0000000000000000000000000000000000000000";
DECLARE RewardRate DEFAULT TokenOffered / CAST(TIMESTAMP_DIFF(CutoffDate, StartDate, SECOND) AS NUMERIC);

# Exclusion list of addresses that wont receive rewards
WITH excluded_list AS (
  SELECT address FROM `minting-incentives.exclusions.excluded_owners`),

# Fetch the list of all RAI LP token transfers (includes mint & burns)
raw_lp_transfers AS (
  SELECT * FROM `bigquery-public-data.crypto_ethereum.token_transfers`
  WHERE block_timestamp >= DeployDate 
    AND block_timestamp <= CutoffDate
    AND token_address = LPTokenAddress
    # Parasite transaction
    AND (from_address != NullAddress OR to_address != NullAddress)
), 

# Calculate the realtive LP token balance delta, outgoing transfer is negative delta
lp_transfers_deltas AS (
  SELECT * FROM (
    SELECT block_timestamp, block_number, log_index, from_address AS address, -1 * CAST(value AS NUMERIC) AS delta_lp FROM raw_lp_transfers
    UNION ALL 
    SELECT block_timestamp, block_number, log_index, to_address AS address, CAST(value AS NUMERIC) AS delta_lp FROM raw_lp_transfers
  )
),

# Keep only records after the start date
lp_transfers_deltas_after AS (
  SELECT * FROM lp_transfers_deltas
  WHERE block_timestamp >= StartDate
),

# Process records before the start date like if everyone prior to strtDate had deposited on start date
lp_transfers_deltas_before AS (
  SELECT  StartDate AS block_timestamp, MAX(block_number) AS block_number, 0 AS log_index, address, SUM(delta_lp) AS delta_lp FROM lp_transfers_deltas
  WHERE block_timestamp <= StartDate
  GROUP BY address
),

# Merge records from before and after
lp_transfers_deltas_on_start AS (
  SELECT block_timestamp, block_number, log_index, address, delta_lp FROM lp_transfers_deltas_before
  UNION ALL 
  SELECT block_timestamp, block_number, log_index, address, delta_lp FROM lp_transfers_deltas_after
),

# Exclude the addresses from the exclusion list
lp_with_exclusions AS (
SELECT * FROM lp_transfers_deltas_on_start
WHERE address NOT IN (SELECT address FROM excluded_list)
),

# Add lp token total_supply and individual balances
lp_total_supply_and_balances AS (
  SELECT * ,
    # Add total_supply of lp token by looking at the balance of 0x0
    SUM(CASE WHEN address = NullAddress THEN -1 * delta_lp ELSE 0 END) OVER(ORDER BY block_timestamp, log_index) AS total_supply,
    # LP balance of each individual address
    SUM(delta_lp) OVER(PARTITION BY address ORDER BY block_timestamp, log_index) AS balance
  FROM lp_with_exclusions
),

# Add the delta_reward_per_token (increase in reward_per_token)
lp_delta_reward_per_token AS (
  SELECT *, 
      COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS NUMERIC), 0) AS delta_t,
      COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER( ORDER BY block_timestamp, log_index), SECOND) AS NUMERIC), 0) * RewardRate / (LAG(total_supply) OVER(ORDER BY block_timestamp, log_index)) AS delta_reward_per_token

  FROM lp_total_supply_and_balances),

# Calculated the actual reward_per_token from the culmulative delta
lp_reward_per_token AS (
  SELECT *,
    SUM(delta_reward_per_token) OVER(ORDER BY block_timestamp, log_index) AS reward_per_token
  FROM lp_delta_reward_per_token
),

# Build a simple list of all paticipants
all_addresses AS (
  SELECT DISTINCT address FROM lp_reward_per_token
),

# Add cutoff events like if everybody had unstaked on cutoff date. We need this to account for people that are still staking on cutoff date.
lp_with_cutoff_events AS (
  SELECT 
    block_timestamp, 
    log_index, 
    address, 
    balance,
    reward_per_token  
  FROM lp_reward_per_token
  
  UNION ALL  

  # Add the cutoff events
  SELECT
    CutoffDate AS block_timestamp,
    # Set it to the highest log index to be sure it comes last
    (SELECT MAX(log_index) FROM lp_reward_per_token) AS log_index,
    address AS address,
    # You unstaked so your balance is 0
    0 AS balance,
    # ⬇ reward_per_token on cutoff date                            ⬇ Time passed since the last update of reward_per_token                                                                              ⬇ latest total_supply
    (SELECT MAX(reward_per_token) FROM lp_reward_per_token) + COALESCE(CAST(TIMESTAMP_DIFF(CutoffDate, (SELECT MAX(block_timestamp) FROM lp_reward_per_token), SECOND) AS NUMERIC), 0) * RewardRate / (SELECT total_supply FROM lp_reward_per_token ORDER BY block_timestamp DESC LIMIT 1) 
    AS reward_per_token
  FROM all_addresses
),

# Credit rewards, basically the earned() function from a staking contract
lp_earned AS (
  SELECT *,
    #                       ⬇ userRewardPerTokenPaid                                                                             ⬇ balance just before 
    (reward_per_token - COALESCE(LAG(reward_per_token,1) OVER(PARTITION BY address ORDER BY block_timestamp, log_index), 0)) * COALESCE(LAG(balance) OVER(PARTITION BY address ORDER BY block_timestamp, log_index),0) AS earned,
  FROM lp_with_cutoff_events
),

# Sum up the earned event per address
final_reward_list AS (
  SELECT address, SUM(earned) AS reward
  FROM lp_earned
  GROUP BY address
)

# Output results
SELECT address, CAST(reward AS NUMERIC)/1e18 AS reward
FROM final_reward_list 
WHERE 
  address != NullAddress AND
  reward > 0
ORDER BY reward DESC
