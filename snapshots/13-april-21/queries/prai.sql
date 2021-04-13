# Exclusion list of addresses that wont receive rewards
WITH excluded_list AS (
  SELECT address FROM `minting-incentives.exclusions.excluded_owners`)

SELECT DISTINCT address, 30 AS reward FROM (
    (
        # Query EOA that interacted with a specific list of contracts
        SELECT tx.from_address as address 
        # Table including all Ethereum transactions
        FROM bigquery-public-data.crypto_ethereum.transactions AS tx
        # Date just before PRAI deployement 
        WHERE tx.block_timestamp > TIMESTAMP("2020-10-24 00:00:00+00")
        # PRAI settlement block
        AND tx.block_number <= 11724918
        # The transaction had to succeed 
        AND tx.receipt_status = 1
        # Need to have interacted with at least one of these contracts
        AND (
            # Proxy factory address
            tx.to_address = "0xf89a0e02af0fd840b0fcf5d103e1b1c74c8b7638" 
            # PRAI token address
            OR tx.to_address = "0x715c3830fb0c4bab9a8e31c922626e1757716f3a"
            # PRAI uniswap pool
            OR tx.to_address = "0xebde9f61e34b7ac5aae5a4170e964ea85988008c"
            # Safe engine (to include unmanged safes)
            OR tx.to_address = "0xf0b7808b940b78be81ad6f9e075ce8be4a837e2c"
        )
    )

    UNION ALL

    (
        # Query to get all non-contract addresses that ever interacted with PRAI
        SELECT to_address as address
        FROM bigquery-public-data.crypto_ethereum.token_transfers AS tx
        # Join contract table to filter out addresses that are contracts
        LEFT JOIN bigquery-public-data.crypto_ethereum.contracts as ctx ON tx.to_address = ctx.address 
        # Exclude all addresses that are a contract 
        WHERE ctx.address IS NULL 
        # Date just before PRAI deployment 
        AND tx.block_timestamp > TIMESTAMP("2020-10-24 00:00:00+00")
        # PRAI settlement block
        AND tx.block_number <= 11724918
        # PRAI token address
        AND token_address = "0x715c3830fb0c4bab9a8e31c922626e1757716f3a"
    )
)

WHERE 
  address NOT IN (SELECT address FROM excluded_list) 
  AND address != "0x0000000000000000000000000000000000000000"
ORDER BY address
