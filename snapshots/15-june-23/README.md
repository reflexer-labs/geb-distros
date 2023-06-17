# FLX Distribution #27

Distribution date: June 2023

- Start: May-15-2023 12:50pm UTC
- Cutoff-date: June-15-2023 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-27/query-results`

### RAI/ETH UNI-V2 LP

30 FLX per day to RAI/ETH LPs on Uniswap.

- Period: From May-15-2023 12:50pm UTC Until June-15-2023 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 930 FLX

### RAI/DAI UNI-V3 LP

0 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From May-15-2023 12:50pm UTC Until June-15-2023 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 0 FLX

### RAI Curve LP

0 FLX per day to RAI Curve LPs (RAI-3CRV LP token holders)

- Period: From May-15-2023 12:50pm UTC Until June-15-2023 12:50pm UTC
- Query `curve.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-26/queries/curve.sql distributions/distribution-26/query-results/curve.csv`

Total FLX distributed: 0 FLX
