# FLX Distribution #6

Distribution date: 17th September 2021

- Start: Aug-15-2021 12:50pm UTC
- Cutoff-date: Sept-15-2021 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-6/query-results`

## Individual distributions

### Idle users

10 FLX per day to RAI lenders on Idle Finance. Rewards to the yearn Idle strategy at `0x5D411D2cde10e138d68517c42bE2808C90c22026` were taken out and redistributed to holder yvRAI at `0x873fB544277FD7b977B196a826459a69E27eA4ea`.

- Period: From Aug-15-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query `idle.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/idle.sql exclusions.csv distributions/distribution-6/query-results/idle.csv`

Total FLX distributed: 310 FLX (274.41 FLX with Yearn users excluded)

### Yearn

Reward attributed to the yearn strategy from the idle distribution are forwarded to yvRAI holders

- Period: From Aug-15-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query: `yv-rai.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/yv-rai.sql exclusions.csv distributions/distribution-6/query-results/yv-rai.sql.csv`

Total FLX distributed: 1.308425377

### Fuse borrower 1

15 FLX per day to RAI borrowers that didn't supply RAI pro rata to the borrow amount.

- Period: From Aug-15-2021 12:50pm UTC Until Aug-25-2021 12:50pm UTC
- Query `fuse-borrower-no-rai-supply-1.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/fuse-borrower-no-rai-supply-1.sql exclusions.csv distributions/distribution-6/query-results/fuse-borrower-no-rai-supply-1.csv`

Total FLX distributed: 150 FLX

### Fuse borrower 2

10 FLX per day to RAI borrowers that didn't supply RAI pro rata to the borrow amount.

- Period: From Aug-25-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query `fuse-borrower-no-rai-supply-2.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/fuse-borrower-no-rai-supply-2.sql exclusions.csv distributions/distribution-6/query-results/fuse-borrower-no-rai-supply-2.csv`

Total FLX distributed: 210 FLX

### Aave borrower 1

65 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From Aug-15-2021 12:50pm UTC Until Aug-25-2021 12:50pm UTC
- Query `aave-1.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/aave-1.sql exclusions.csv distributions/distribution-6/query-results/aave-1.csv`

The following DefiSaver users rewards was reassigned to their respective EOA:

RAI borrower EOA, RAI borrower dsproxy
0xf2e563f6fbf25cf23dbe57d25287e10339ad3b6f, 0x7e983F042fB16eE5d4A621D44779F8724c2383ee
0xce824663bccb32e2dad1a8f2a26b698290417b34, 0x192f84b53538Af908312380F8547260adb310D6e
0xe519f4cd2803ba53a40e6377e82406e548418660, 0x3092cfd86Ed8c95D8525766eD2110f7667330222
0x1aa5abfd850012297428b509fb84fcd9f9f995cb, 0xfC72CB97E2e2D0834d4908FbA298e7Ff4fD1E465
0x0e134124dad59b5b3b219ad40de7143140799b39, 0x382eD27251923a122cED2bb253f8ac6849f7f230
0x6ada4e93aa63f395a66444db475f0f56f4f3ca4f, 0xBe3809E3EB2de2d38A4851A330e9Ec7ABFEd1de4
0xa5a97c284c8718972e475fe5ce988c466022b074, 0xc09d86f59d25E24DF5D6168fE11bE9145D9aF709

Total FLX distributed: 650 FLX

### Aave borrower 2

40 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From Aug-25-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query `aave-2.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/aave-2.sql exclusions.csv distributions/distribution-6/query-results/aave-2.csv`

The following DefiSaver users rewards was reassigned to their respective EOA:

RAI borrower EOA, RAI borrower dsproxy
0xf2e563f6fbf25cf23dbe57d25287e10339ad3b6f, 0x7e983F042fB16eE5d4A621D44779F8724c2383ee
0xce824663bccb32e2dad1a8f2a26b698290417b34, 0x192f84b53538Af908312380F8547260adb310D6e
0xe519f4cd2803ba53a40e6377e82406e548418660, 0x3092cfd86Ed8c95D8525766eD2110f7667330222
0x1aa5abfd850012297428b509fb84fcd9f9f995cb, 0xfC72CB97E2e2D0834d4908FbA298e7Ff4fD1E465
0x0e134124dad59b5b3b219ad40de7143140799b39, 0x382eD27251923a122cED2bb253f8ac6849f7f230
0x6ada4e93aa63f395a66444db475f0f56f4f3ca4f, 0xBe3809E3EB2de2d38A4851A330e9Ec7ABFEd1de4
0xa5a97c284c8718972e475fe5ce988c466022b074, 0xc09d86f59d25E24DF5D6168fE11bE9145D9aF709

Total FLX distributed: 840 FLX

### RAI/ETH UNI-V2 LP 1

334 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From Aug-15-2021 12:50pm UTC Until Aug-18-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 1002 FLX

### RAI/ETH UNI-V2 LP 2

290 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From Aug-18-2021 12:50pm UTC Until Aug-25-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 2030 FLX

### RAI/ETH UNI-V2 LP 3

220 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From Aug-25-2021 12:50pm UTC Until Sept-1-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 1320 FLX

### RAI/ETH UNI-V2 LP 4

170 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From Sept-1-2021 12:50pm UTC Until Sept-8-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 1190 FLX

### RAI/ETH UNI-V2 LP 5

120 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From Sept-8-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 840 FLX

### RAI/DAI UNI-V3 LP 1

50 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From Aug-15-2021 12:50pm UTC Until Aug-18-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 150 FLX

### RAI/DAI UNI-V3 LP 2

50 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From Aug-18-2021 12:50pm UTC Until Aug-25-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 588 FLX

### RAI/DAI UNI-V3 LP 3

50 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From Aug-25-2021 12:50pm UTC Until Sept-1-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 684 FLX

### RAI/DAI UNI-V3 LP 4

50 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From Sept-1-2021 12:50pm UTC Until Sept-8-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 1008 FLX

### RAI/DAI UNI-V3 LP 5

50 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From Sept-8-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 1218 FLX

### FLX/ETH UNI-V2 LP 1

90 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From Aug-15-2021 12:50pm UTC Until Sept-01-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp-1.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/flx-eth-uni-v2-lp-1.sql exclusions.csv distributions/distribution-6/query-results/flx-eth-uni-v2-lp-1.csv`

Rewards to the FLX staking contract at 0x82daf3b6fcd7d4b27cd9c6dbb6be93a7b38570ae are redistributed to stakers at 0x353efac5cab823a41bc0d6228d7061e92cf9ccb0

- Query `flx-eth-uni-v2-lp-redistribute-1.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/flx-eth-uni-v2-lp-redistribute-1.sql exclusions.csv distributions/distribution-6/query-results/flx-eth-uni-v2-lp-redistribute-1.csv`

Total FLX distributed: 1530 FLX

### FLX/ETH UNI-V2 LP 2

50 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From Sept-01-2021 12:50pm UTC Until Sept-15-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp-2.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/flx-eth-uni-v2-lp-2.sql exclusions.csv distributions/distribution-6/query-results/flx-eth-uni-v2-lp-2.csv`

Rewards to the FLX staking contract at 0x82daf3b6fcd7d4b27cd9c6dbb6be93a7b38570ae are redistributed to stakers at 0x353efac5cab823a41bc0d6228d7061e92cf9ccb0

- Query `flx-eth-uni-v2-lp-redistribute-2.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-6/queries/flx-eth-uni-v2-lp-redistribute-2.sql exclusions.csv distributions/distribution-6/query-results/flx-eth-uni-v2-lp-redistribute-2.csv`

Total FLX distributed: 700 FLX

### Additional distributions

34.470137408 FLX to 0x75C4f5c54418b34F288C91de878e69729F391f74 who forgot to claim round #2
