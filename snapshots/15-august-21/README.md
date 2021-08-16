# FLX Distribution #5

Distribution date: 17th August 2021

- Start: July-15-2021 12:50pm UTC
- Cutoff-date: Aug-15-2021 12:50pm UTC

Results of the overall distribution are in `per_campaign.csv` for individual query results for each distribution and in `summed.csv` which is the final file used for generating the Merkle root for the distributor contract.

To combine the individual query results run `./run_combine.sh ./distributions/distribution-5/query-results`

## Individual distributions

### Fuse borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From July-15-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query `fuse-borrower-no-rai-supply.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/fuse-borrower-no-rai-supply.sql exclusions.csv distributions/distribution-5/query-results/fuse-borrower-no-rai-supply.csv`

Total FLX distributed: 465 FLX

### Kashi borrower

10 FLX per day to RAI borrowers on the RAI/DAI Kashi pair.

- Period: From July-15-2021 12:50pm UTC Until July-21-2021 12:50pm UTC
- Query `kashi.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/kashi.sql exclusions.csv distributions/distribution-5/query-results/kashi.csv`

Total FLX distributed: 60 FLX

### RAI/ETH UNI-V2 LP

334 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From July-15-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 10354 FLX

### FLX/ETH UNI-V2 LP 1

80 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From July-15-2021 12:50pm UTC Until July-21-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp-1.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/flx-eth-uni-v2-lp-1.sql exclusions.csv distributions/distribution-5/query-results/flx-eth-uni-v2-lp-1.csv`

Total FLX distributed: 480 FLX

### FLX/ETH UNI-V2 LP 2

90 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From July-21-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp-2.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/flx-eth-uni-v2-lp-2.sql exclusions.csv distributions/distribution-5/query-results/flx-eth-uni-v2-lp-2.csv`

Total FLX distributed: 2250 FLX

### Idle users

10 FLX per day to RAI lenders on Idle Finance. Rewards to the yearn Idle strategy at `0x5D411D2cde10e138d68517c42bE2808C90c22026` were taken out and redistributed to holder yvRAI at `0x873fB544277FD7b977B196a826459a69E27eA4ea`. 

- Period: From July-15-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query `idle.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/idle.sql exclusions.csv distributions/distribution-5/query-results/idle.csv`

Total FLX distributed: 310 FLX (274.41 FLX with Yearn users excluded)


### Yearn

Reward attributed to the yearn strategy from the idle distribution are forwarded to yvRAI holders

- Period: From July-15-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query: `yv-rai.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/yv-rai.sql exclusions.csv distributions/distribution-5/query-results/yv-rai.sql.csv`

Total FLX distributed: 35.62284692

### Aave borrower

65 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From July-15-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query `aave.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-5/queries/aave.sql exclusions.csv distributions/distribution-5/query-results/aave.csv`

The following DefiSaver users rewards was reassigned to their respective EOA:

RAI borrower EOA, RAI borrower dsproxy
0xf2e563f6fbf25cf23dbe57d25287e10339ad3b6f, 0x7e983F042fB16eE5d4A621D44779F8724c2383ee
0xce824663bccb32e2dad1a8f2a26b698290417b34, 0x192f84b53538Af908312380F8547260adb310D6e
0xe519f4cd2803ba53a40e6377e82406e548418660, 0x3092cfd86Ed8c95D8525766eD2110f7667330222
0x1aa5abfd850012297428b509fb84fcd9f9f995cb, 0xfC72CB97E2e2D0834d4908FbA298e7Ff4fD1E465
0x0e134124dad59b5b3b219ad40de7143140799b39, 0x382eD27251923a122cED2bb253f8ac6849f7f230

Total FLX distributed: 2015 FLX

### RAI/DAI UNI-V3 LP 1

28.5714 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From July-15-2021 12:50pm UTC Until July-23-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 228.5712 FLX

### RAI/ETH UNI-V3 LP

28.5714 FLX per day to RAI/ETH Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From July-15-2021 12:50pm UTC Until July-23-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 228.5712 FLX

### RAI/DAI UNI-V3 LP 2

50 FLX per day to RAI/DAI Uniswap v3 LPs at Redemption price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From July-23-2021 12:50pm UTC Until Aug-9-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 850 FLX

### RAI/DAI UNI-V3 LP 3

50 FLX per day to RAI/DAI Uniswap v3 LPs at Market price that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From Aug-9-2021 12:50pm UTC Until Aug-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 450 FLX




############################################################################################


### Cream borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From June-17-2021 12:50pm UTC Until June-23-2021 12:50pm UTC
- Query `cream-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/cream-borrower.sql exclusions.csv distributions/distribution-4/query-results/cream-borrower.csv`

Total FLX distributed: 90 FLX

### Fuse borrower

15 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From June-17-2021 12:50pm UTC UTC Until July-07-2021 12:50pm UTC
- Query `fuse-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/fuse-borrower.sql exclusions.csv distributions/distribution-4/query-results/fuse-borrower.csv`

Total FLX distributed: 300 FLX

### Fuse borrower that didn't supply RAI

15 FLX per day to RAI borrowers that didn't supply RAI.

- Period: From July-07-2021 12:50pm UTC UTC Until July-15-2021 12:50pm UTC
- Query `fuse-borrower.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/fuse-borrower-no-rai-supply.sql exclusions.csv distributions/distribution-4/query-results/fuse-borrower-no-rai-supply.csv`

Total FLX distributed: 120 FLX

### Kashi borrower

10 FLX per day to RAI borrowers on the RAI/DAI Kashi pair.

- Period: From June-17-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query `kashi.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/kashi.sql exclusions.csv distributions/distribution-4/query-results/kashi.csv`

Total FLX distributed: 280 FLX

### RAI/ETH UNI-V2 LP

334 FLX per day to RAI/ETH LPs on Uniswap that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-mint-+-lp-incentives-program`

- Period: From June-17-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/lp-minter-reward-script

Total FLX distributed: 9352 FLX

### FLX/ETH UNI-V2 LP 1

40 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From June-17-2021 12:50pm UTC Until June-21-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp-1.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/flx-eth-uni-v2-lp-1.sql exclusions.csv distributions/distribution-4/query-results/flx-eth-uni-v2-lp-1.csv`

Total FLX distributed: 160 FLX

### FLX/ETH UNI-V2 LP 2

80 FLX per day to FLX/ETH LPs on Uniswap V2. See `https://docs.reflexer.finance/incentives/flx-liquidity-incentives`

- Period: From June-21-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query `flx-eth-uni-v2-lp-2.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/flx-eth-uni-v2-lp-2.sql exclusions.csv distributions/distribution-4/query-results/flx-eth-uni-v2-lp-2.csv`

Total FLX distributed: 1920 FLX

### Idle users

10 FLX per day to RAI lenders on Idle Finance. Rewards to the yearn Idle strategy at `0x5D411D2cde10e138d68517c42bE2808C90c22026` were taken out and redistributed to holder yvRAI at `0x873fB544277FD7b977B196a826459a69E27eA4ea`. 

- Period: From June-17-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query `ilde.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/idle.sql exclusions.csv distributions/distribution-4/query-results/idle.csv`

Total FLX distributed: 203.78077123 FLX


### Yearn

Reward attributed to the yearn strategy from the idle distribution are forwarded to yvRAI holders

- Period: From June-17-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query: `yv-rai.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/yv-rai.sql exclusions.csv distributions/distribution-4/query-results/yv-rai.sql.csv`

Total FLX distributed: 76.21922877

### Aave borrower

65 FLX per day to RAI borrowers pro rata to the borrow amount.

- Period: From June-23-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query `aave.sql`
- Command `./run_incentives_query.sh ./distributions/distribution-4/queries/aave.sql exclusions.csv distributions/distribution-4/query-results/aave.csv`

The following DefiSaver users rewards was reassigned to their respective EOA:

RAI borrower EOA, RAI borrower dsproxy
0xf2e563f6fbf25cf23dbe57d25287e10339ad3b6f, 0x7e983F042fB16eE5d4A621D44779F8724c2383ee
0xce824663bccb32e2dad1a8f2a26b698290417b34, 0x192f84b53538Af908312380F8547260adb310D6e
0xe519f4cd2803ba53a40e6377e82406e548418660, 0x3092cfd86Ed8c95D8525766eD2110f7667330222

Total FLX distributed: 1430 FLX

### RAI/ETH UNI-V3 LP

28.5714 FLX per day to RAI/ETH Uniswap v3 LPs that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From July-09-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 171.42857 FLX

### RAI/DAI UNI-V3 LP

28.5714 FLX per day to RAI/DAI Uniswap v3 LPs that also minted RAI. See `https://docs.reflexer.finance/incentives/rai-uniswap-v3-mint-+-lp-incentives-program`

- Period: From July-09-2021 12:50pm UTC Until July-15-2021 12:50pm UTC
- Query: Node script at https://github.com/reflexer-labs/uni-v3-incentive-reward-script

Total FLX distributed: 171.42857 FLX