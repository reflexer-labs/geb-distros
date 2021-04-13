# Distribution Details

Distribution date: April-15-2021

- Start: Before PRAI deployment on 24.10.2020
- Cutoff-date: April-13-2021 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-1/query-results`

## Individual distributions

### PRAI users

30 FLX for every addresses that interacted with the PRAI mainnet beta. Includes Safe Owner LPs, RAI traders on Uniswap.

Period: From the deployment of PRAI until it global settlement on Jan-25-2021 12:43:21 PM UTC (Block 11724918)
Query: `./queries/prai.sql`
Command: `./run_incentives_query.sh ./queries/prai.sql exclusions.csv distributions/distribution-1/query-results/prai.csv`

Total FLX distributed: 6870

### RAI Period 1

668 FLX per day to RAI/ETH Uniswap LPs pro rata to their LP token balance.

- Period: From Feb-17-2021 1:50 PM UTC Until Feb-20-2021 10:25 PM UTC
- Query: `./queries/lp-reward-1.sql`
- Command: `./run_incentives_query.sh ./queries/lp-reward-1.sql exclusions.csv distributions/distribution-1/query-results/lp-reward-1.csv`

Total FLX distributed: 2242.9028

### RAI Period 2

668 FLX per day. Half to RAI/ETH Uniswap LPs pro rata to their LP token balance and the other half for RAI minters pro rata to their debt.

- Period: From Feb-20-2021 10:25 PM UTC Until Feb-26-2021 1:50 PM UTC
- Queries: `./queries/lp-reward-2.sql` (LP) `minting-rewards-1.sql` (RAI minters)
- Commands:

```
./run_incentives_query.sh ./queries/lp-reward-2.sql exclusions.csv distributions/distribution-1/query-results/lp-reward-2.csv
./run_incentives_query_with_owner_mapping.sh ./queries/minting-reward-1.sql exclusions.csv distributions/distribution-1/query-results/minting-reward-1.csv

```

Total FLX distributed: 3769.0972 (2 \* 1884.5486)

### RAI Period 3

668 FLX per day. 668 FLX per day to RAI/ETH Uniswap LPs pro rata to their LP token balance.

- Period: From Feb-26-2021 1:50 PM UTC Until March-8-2021 1:50 PM UTC
- Query: `./queries/lp-reward-3.sql`
- Command: `./run_incentives_query.sh ./queries/lp-reward-3.sql exclusions.csv distributions/distribution-1/query-results/lp-reward-3.csv`

Total FLX distributed: 6680

### RAI Period 4

668 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: March-8-2021 1:50 PM UTC Until April-13-2021 12:50 PM UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 24048

### Cream borrower 1

25 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From March 31-2021 12:50 PM UTC Until April-7-2021 12:50 UTC
- Query `cream-borrower-1.sql`
- Command `./run_incentives_query.sh ./queries/cream-borrower-1.sql exclusions.csv distributions/distribution-1/query-results/cream-borrower-1.csv`

Total FLX distributed: 175 FLX

### Cream borrower 2

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From April-7-2021 12:50 UTC Until April-13-2021 12:50 UTC
- Query `cream-borrower-1.sql`
- Command `./run_incentives_query.sh ./queries/cream-borrower-2.sql exclusions.csv distributions/distribution-1/query-results/cream-borrower-2.csv`

Total FLX distributed: 90 FLX

### Flat FLX reward for Safe owner

1 FLX reward for each address that kept a safe open with more than zero debt for at least a week cumulated.

- Period: From Feb-13-2021 (Initial deployment of the system) Until April-13-2021 12:50 UTC
- Query `./flat-reward.sql`
- Command: `./run_incentives_query_with_owner_mapping.sh ./queries/flat-reward.sql exclusions.csv distributions/distribution-1/query-results/flat-reward.csv`

Total FLX distributed: 1211
