# FLX Distribution #3

Distribution date: 22th June 2021

- Start: May-13-2021 12:50pm UTC
- Cutoff-date: June-17-2021 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-3/query-results`

## Individual distributions

### Cream borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From May-13-2021 12:50pm UTC Until June-17-2021 12:50pm UTC
- Query `cream-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-3/queries/cream-borrower.sql exclusions.csv distributions/distribution-3/query-results/cream-borrower.csv`

Total FLX distributed: 525 FLX

### Fuse borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From May-13-2021 12:50pm UTC Until June-17-2021 12:50pm UTC
- Query `fuse-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-3/queries/fuse-borrower.sql exclusions.csv distributions/distribution-3/query-results/fuse-borrower.csv`

Total FLX distributed: 525 FLX

### RAI/ETH UNI-V2 LP 1

233.8 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From May-13-2021 12:50pm UTC Until May-26-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 3039.4 FLX

### RAI/ETH UNI-V2 LP 2

334 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From May-26-2021 12:50pm UTC Until June-17-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 7348 FLX


### RAI/DAI UNI-V2 LP

100.2 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From May-13-2021 12:50pm UTC Until May-26-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 1328.6 FLX

### Kashi borrower

10 FLX per day to RAI borrowers on the RAI/DAI Kashi pair.

- Period: From May-19-2021 12:50pm UTC Until June-17-2021 12:50pm UTC
- Query `kashi.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-3/queries/kashi.sql exclusions.csv distributions/distribution-3/query-results/kashi.csv`

Total FLX distributed: 290 FLX

### Idle users

10 FLX per day to RAI lenders on Idle Finance. Rewards to the yearn Idle strategy at `0x5D411D2cde10e138d68517c42bE2808C90c22026` were taken out and redistributed to holder yvRAI at `0x873fB544277FD7b977B196a826459a69E27eA4ea`. 

- Period: From May-26-2021 12:50pm UTC Until June-17-2021 12:50pm UTC
- Query `ilde.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-3/queries/idle.sql exclusions.csv distributions/distribution-3/query-results/idle.csv`

Total FLX distributed: 220 FLX

### Yearn

Reward attributed to the yearn strategy from the idle distribution are forwarded to yvRAI holders

- Period: From June-07-2021 04:37:06pm UTC Until June-17-2021 12:50pm UTC
- Query: `yv-rai.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-3/queries/yv-rai.sql exclusions.csv distributions/distribution-3/query-results/yv-rai.sql.csv`

Total FLX distributed: 18.029974241

### FLX/ETH UNI-V2 LP

40 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From May-14-2021 12:50pm UTC Until June-17-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-3/queries/flx-eth-uni-v2-lp.sql exclusions.csv distributions/distribution-3/query-results/flx-eth-uni-v2-lp.csv`

Total FLX distributed: 120 FLX

### Loopring LP Round 8

50 FLX in total for the loopring liquidity mining campaign round 7. The reward numbers were provided by the Loopring team.
See: `https://medium.com/loopring-protocol/loopring-l2-liquidity-mining-round-8-c4b85a00f0a9`

Results were summed with this script: `https://gist.github.com/guifel/0c0bdc473957cd85b3778df18a1da795`

- Period: From May-13-2021 00:00 UTC for 13 days

Total FLX distributed: 50

### Loopring LP Round 9

50 FLX in total for the loopring liquidity mining campaign round 7. The reward numbers were provided by the Loopring team.
See: `https://medium.com/loopring-protocol/loopring-l2-liquidity-mining-round-9-49746231a656`

Results were summed with this script: `https://gist.github.com/guifel/613a84d2704d95cd70d3b0ffcdffded0`

- Period: From May-27-2021 00:00 UTC for 13 days

Total FLX distributed: 50