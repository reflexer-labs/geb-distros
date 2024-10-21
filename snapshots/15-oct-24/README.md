# FLX Distribution #43

Please see forum thread [here](https://community.reflexer.finance/t/oracle-migration-to-uniswap-v3-incentive-adjustments/510/22) for details on incentive changes from last month.

Distribution date: October 2024

- Start: August-15-2024 12:50pm UTC
- Cutoff-date: October-15-2024 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-40/query-results`

### RAI/ETH UNI-V2 LP

0 FLX per day to RAI/ETH LPs on Uniswap.

- Period: From August-15-2024 12:50pm UTC Until October-15-2024 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 0 FLX

### RAI/ETH UNI-V3 LP

30 FLX per day to RAI/ETH Uniswap v3 LPs at full range. See `https://docs.reflexer.finance/incentives/rai-eth-uniswap-v3-oracle-lp-incentives-program`

- Period: From August-15-2024 12:50pm UTC Until October-15-2024 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 900 FLX

### RAI/DAI UNI-V3 LP

0 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From August-15-2024 12:50pm UTC Until October-15-2024 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 0 FLX

### RAI Curve LP

0 FLX per day to RAI Curve LPs (RAI-3CRV LP token holders)

- Period: From August-15-2024 12:50pm UTC Until October-15-2024 12:50pm UTC
- Query `curve.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-40/queries/curve.sql distributions/distribution-40/query-results/curve.csv`

Total FLX distributed: 0 FLX
