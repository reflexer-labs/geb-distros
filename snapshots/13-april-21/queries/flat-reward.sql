DECLARE CutoffDate DEFAULT TIMESTAMP("2021-04-13 12:50:00+00");
# Snapshot for the safe ownership, use the block of the CutoffDate
DECLARE CutoffBlock DEFAULT 12231841; 
DECLARE TimeThreshold DEFAULT 604800; # One week
DECLARE Reward DEFAULT 1;

WITH modify_safe_collateralization AS (
    SELECT block_timestamp, log_index, safe, CAST(deltaDebt AS BIGNUMERIC) as deltaDebt 
    FROM `blockchain-etl.ethereum_rai.SAFEEngine_event_ModifySAFECollateralization`
),
confiscate_safe_collateral_and_debt as (
    SELECT block_timestamp, log_index, safe, CAST(deltaDebt AS BIGNUMERIC) as deltaDebt 
    FROM `blockchain-etl.ethereum_rai.SAFEEngine_event_ConfiscateSAFECollateralAndDebt`
),
transfer_safe_collateral_and_debt_in AS (
    SELECT block_timestamp, log_index, dst AS safe, CAST(deltaDebt AS BIGNUMERIC) AS deltaDebt 
    FROM `blockchain-etl.ethereum_rai.SAFEEngine_event_TransferSAFECollateralAndDebt`
),
transfer_safe_collateral_and_debt_out AS (
    SELECT block_timestamp, log_index, src AS safe, -1 * CAST(deltaDebt AS BIGNUMERIC) AS deltaDebt,  
    FROM `blockchain-etl.ethereum_rai.SAFEEngine_event_TransferSAFECollateralAndDebt`
), 
all_safe_modifications AS (
    SELECT * FROM (
        SELECT * FROM modify_safe_collateralization
        UNION ALL 
        SELECT * FROM confiscate_safe_collateral_and_debt
        UNION ALL 
        SELECT * FROM transfer_safe_collateral_and_debt_in
        UNION ALL 
        SELECT * FROM transfer_safe_collateral_and_debt_out)
    WHERE block_timestamp <= CutoffDate
),
debt_balance AS (
    SELECT 
        block_timestamp,
        log_index,
        safe,
        SUM(deltaDebt) OVER(PARTITION BY safe ORDER BY block_timestamp, log_index) AS debt,
    FROM all_safe_modifications
),
time_with_debt AS (
    SELECT 
        safe,
        IF(
            COALESCE(LAG(debt) OVER(PARTITION BY safe ORDER BY block_timestamp, log_index), 0) > 1,
            COALESCE(CAST(TIMESTAMP_DIFF(block_timestamp, LAG(block_timestamp) OVER(PARTITION BY safe ORDER BY block_timestamp, log_index), SECOND) AS NUMERIC), 0),
            0
        ) AS delta_t
    FROM (
        SELECT * FROM debt_balance
        UNION ALL 
        SELECT CutoffDate AS block_timestamp, (SELECT MAX(log_index) FROM debt_balance) AS log_index, safe, 0 as debt FROM debt_balance
        
        )
),
address_time_with_debt AS (
  SELECT safe, SUM(delta_t) as time
  FROM time_with_debt
  GROUP BY safe
),

# Exclusion list of addresses that wont receive rewards, lower case only!
excluded_list AS (
  SELECT * FROM `minting-incentives.exclusions.excluded_owners` as address
),


# Safe <> Owner mapping
safe_owners AS (
  SELECT block, safe, owner
  from `minting-incentives.safe_owners.safe_owners`
  WHERE
    block = CutoffBlock
)

SELECT safe_owners.owner as address, Reward
FROM address_time_with_debt INNER JOIN safe_owners ON safe_owners.safe=address_time_with_debt.safe
# Need to have debt for long enough and not be on the exlcusion list 
WHERE time > TimeThreshold AND safe_owners.owner NOT IN (SELECT address FROM excluded_list)
# You still get only 1 reward if you have several safes
GROUP BY safe_owners.owner
ORDER BY MAX(time) DESC