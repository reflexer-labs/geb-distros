# FLX Distribution #2

Distribution date: TBD

- Start: April-13-2021 12:50pm UTC
- Cutoff-date: May-13-2021 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-2/query-results`

## Individual distributions

### RAI RAI/ETH UNI-V2 LP 1

668 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From April-13-2021 12:50pm UTC Until April-17-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 2672 FLX

### RAI RAI/ETH UNI-V2 LP 2

233.8 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From April-17-2021 12:50pm UTC Until May-13-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 6078.8 FLX

### RAI RAI/DAI UNI-V2 LP

100.2 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From April-17-2021 12:50pm UTC Until May-13-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 2605.2 FLX

### Cream borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From April-13-2021 12:50pm UTC Until May-13-2021 12:50pm UTC
- Query `cream-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-2/queries/cream-borrower.sql exclusions.csv distributions/distribution-2/query-results/cream-borrower.csv`

Total FLX distributed: 450 FLX

### Fuse borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From April-14-2021 12:50pm UTC Until May-13-2021 12:50pm UTC
- Query `fuse-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-2/queries/fuse-borrower.sql exclusions.csv distributions/distribution-2/query-results/fuse-borrower.csv`

Total FLX distributed: 435 FLX

### Loopring LP

50 FLX in total for the loopring liquidity mining campaign round 7. The reward numbers were provided by the Loopring team.
See: `https://medium.com/loopring-protocol/loopring-l2-liquidity-mining-round-7-36a954d2d78`

Results were summed with this script: `https://gist.github.com/guifel/2e8e86c62b3368e3217b48bc1b7b9bfd`

- Period: From April-29-2021 00:00 UTC Until May-10-2021 23:59pm UTC

Total FLX distributed: 50