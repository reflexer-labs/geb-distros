# FLX Distribution #17

Distribution date: 19th August 2022

- Start: July-15-2022 12:50pm UTC
- Cutoff-date: August-15-2022 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-17/query-results`

### RAI/ETH UNI-V2 LP

50 FLX per day to RAI/ETH LPs on Uniswap.

- Period: From July-15-2022 12:50pm UTC Until August-15-2022 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 1240 FLX

### RAI/DAI UNI-V3 LP

140 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From July-15-2022 12:50pm UTC Until August-15-2022 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 2480 FLX
