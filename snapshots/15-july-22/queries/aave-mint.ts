import Axios from "axios";
import * as fs from "fs";

const RAI_SUBGRAPH = "https://subgraph.reflexer.finance/subgraphs/name/reflexer-labs/rai";

const REWARD_AMOUNT = 300;
const aRaiReward = [
  {
    address: "0x5c960a3dcc01be8a0f49c02a8cebcacf5d07fabe",
    reward: "0.380686791",
  },
  {
    address: "0x02cbe7feaa8b969acc43ab368b6ed45cb63f3354",
    reward: "0.334121516",
  },
  {
    address: "0x464c71f6c2f760dda6093dcb91c24c39e5d6e18c",
    reward: "0.141909595",
  },
  {
    address: "0x1cc926994303219b0decddb907e85ca6200fee3d",
    reward: "0.116547081",
  },
  {
    address: "0xbb010417b1cf4491324078629f3118ef46575ee9",
    reward: "0.094612263",
  },
  {
    address: "0x8cc6a1ae38743d453f2522c5228b775d145f43b7",
    reward: "0.048733302",
  },
  {
    address: "0x8922499e09347826bd4b247b187a135b56d2d625",
    reward: "0.032165203",
  },
  {
    address: "0x8697cb1d4b8c981e9da72bb0cff452771ab10907",
    reward: "0.024160919",
  },
  {
    address: "0xfa8f11e4ad7bc8c7f210bc646d9a23bad4603f49",
    reward: "0.023411459",
  },
  {
    address: "0x8b4a8c1f32761d820d12015b293d24a2ec1b47e9",
    reward: "0.021654252",
  },
  {
    address: "0x7cd7a5a66d3cd2f13559d7f8a052fa6014e07d35",
    reward: "0.020678333",
  },
  {
    address: "0x5a0d6d0de7c74899f09d3509a429beb7d3b4b1d0",
    reward: "0.019091224",
  },
  {
    address: "0x70b8cfdb465c3bb92ffa4673c5636cd17a8cc277",
    reward: "0.014972087",
  },
  {
    address: "0x616f29b6a5b05b76eb04347cd30ed10abe9d5ec2",
    reward: "0.013369798",
  },
  {
    address: "0xab88ac3af5c9aeb1a1a2043495374568eb439244",
    reward: "0.012922836",
  },
  {
    address: "0xf94841dafa3d449d47b539758ca92263f23834b8",
    reward: "0.012541762",
  },
  {
    address: "0xeea7dfe54fdf91d4a05ca0f5e8847f5e9a25d606",
    reward: "0.01245853",
  },
  {
    address: "0x867792c1cae06f418be82cd23decd0fca4272a13",
    reward: "0.010952565",
  },
  {
    address: "0x5ebeaf3f9dee033c12d527d7aa18478073833080",
    reward: "0.009238063",
  },
  {
    address: "0x2e920380a239d8a6467868e3160a69c845fa0ca2",
    reward: "0.00886322",
  },
  {
    address: "0x9730299b10a30bdbaf81815c99b4657c685314ab",
    reward: "0.008569826",
  },
  {
    address: "0x53b79693a00a0af0c9dd2ce91be46475bfb63e6b",
    reward: "0.008510549",
  },
  {
    address: "0xe21e9593620983102d9e7868caaadf514e23e55c",
    reward: "0.008254678",
  },
  {
    address: "0x5ee08f40b637417bcc9d2c51b62f4820ec9cf5d8",
    reward: "0.006788791",
  },
  {
    address: "0x9ff797e6076b27d9218327ebcdb5e4faf41ce800",
    reward: "0.005911454",
  },
  {
    address: "0xa00c99f5f955552742f1089ded88abdc74e67bac",
    reward: "0.004347109",
  },
  {
    address: "0x6c9c5ce574f160a45bd8411e20fa647c2b112a1e",
    reward: "0.003392488",
  },
  {
    address: "0xc9bc48c72154ef3e5425641a3c747242112a46af",
    reward: "0.003304742",
  },
  {
    address: "0x22833a5e77d39d08c8391d421eb4eef67d13f81e",
    reward: "0.003057605",
  },
  {
    address: "0x43a167c2efdc7b137bea81d5a366d42a5d398b6c",
    reward: "0.002979196",
  },
  {
    address: "0x9f4009b5a95486e0759a2449558fe0dbcbd23c87",
    reward: "0.00254593",
  },
  {
    address: "0x4f5ef03e870332a1b42453bbf57b8a041e89efe8",
    reward: "0.002310202",
  },
  {
    address: "0x7136fbddd4dffa2369a9283b6e90a040318011ca",
    reward: "0.002255844",
  },
  {
    address: "0x5fe663a8c35d8e7f6588a4aa53ac537bb8b2aa5b",
    reward: "0.001477095",
  },
  {
    address: "0xff32e57ceed15c2e07e03984bba66c220c06b13a",
    reward: "0.001451922",
  },
  {
    address: "0x02faf62267bdb6bf1a87144b658660c934fdfd34",
    reward: "0.001450362",
  },
  {
    address: "0x7c7da71af75ab8c97910b6b1de28b7ef20c4184f",
    reward: "0.001116425",
  },
  {
    address: "0xc69182d1ab70e268228382383d6886965c5d07a1",
    reward: "0.001115592",
  },
  {
    address: "0x413c3531f3d5a9248d031b4b5cb2de7b1ba8b7f4",
    reward: "0.001045427",
  },
  {
    address: "0x8da6bd2c9526fd3bb3b1a20540edc4b2f8affe2c",
    reward: "0.001003134",
  },
  {
    address: "0x7adafe0c808f1bcea7055c5b205d4bbbcd2d24b6",
    reward: "0.000950211",
  },
  {
    address: "0xfaa987318c328d32d359ad7ce053be5b395da7b7",
    reward: "0.000891686",
  },
  {
    address: "0x7e1e1c5ac70038a9718431c92a618f01f8dada18",
    reward: "0.000816613",
  },
  {
    address: "0xfd78c4a60b993b03c9038d8d8784fa13a56ad67e",
    reward: "0.000740753",
  },
  {
    address: "0x7e886d20a2bb33c9b04a9ee1baf894793f884a46",
    reward: "0.000737308",
  },
  {
    address: "0xf23d10c4a34ecd11600fa640b72c66a19587d4ab",
    reward: "0.000643086",
  },
  {
    address: "0x6ba6832887d051e5d7bcc0ee0dc0eac21279187c",
    reward: "0.000633938",
  },
  {
    address: "0x652880de887495f956bbf66e76c127b59791e510",
    reward: "0.000617562",
  },
  {
    address: "0x1f7e400121c739a10abc18eacfd73b89c6c80ebd",
    reward: "0.000593006",
  },
  {
    address: "0xe005cf408e12c08e3b00ddd4552af14b3ccded5a",
    reward: "0.000576887",
  },
  {
    address: "0x2727a2ec0fb0405c2952cbee98695b68f689cb92",
    reward: "0.000554554",
  },
  {
    address: "0x9b66489819028e28df4f8e28ef26fc0bbd091256",
    reward: "0.000542853",
  },
  {
    address: "0xd7949d974d8f1232ce20329ffc90c81557a6bf3b",
    reward: "0.000409405",
  },
  {
    address: "0xdecc5aaa3b97482097b54c2cc3e8cd9ac8ed4821",
    reward: "0.000312366",
  },
  {
    address: "0xf0065194295e26ba520b65758b01b84e31622891",
    reward: "0.000301471",
  },
  {
    address: "0x500f736f569b801e12cbdd5d8116ea0717512520",
    reward: "0.000247007",
  },
  {
    address: "0x730fac4c4ff284434ef81072341100bb02c2fa49",
    reward: "0.000223118",
  },
  {
    address: "0x885b47ffb619d50871468693a8a9b32b399f9ef1",
    reward: "0.000215112",
  },
  {
    address: "0x5d8b04e983a2f83174530a3574e89f42e5ee066e",
    reward: "0.000212382",
  },
  {
    address: "0xb7857d5a1888889bcd033b5a8eea33e4ff7ef684",
    reward: "0.00021197",
  },
  {
    address: "0xeb4ef1ec65a2337b35c003ec8a1e5d5f75dadcc9",
    reward: "0.00019725",
  },
  {
    address: "0x2af2b2e485e1854fd71590c7ffd104db0f66f8a6",
    reward: "0.00019231",
  },
  {
    address: "0xc98c0068d6c42fe1d68d76bda6b0dda46a7b1a55",
    reward: "0.000185213",
  },
  {
    address: "0x0773a556b1b3351a61b18fcb25a33baad87b7fbb",
    reward: "0.00018103",
  },
  {
    address: "0x08d217f1c3fca1fb21860a1df9b7f2ce5cca067c",
    reward: "0.000178642",
  },
  {
    address: "0x652368b37d2e5b977e492ee07e0be9dfa74169fc",
    reward: "0.000154203",
  },
  {
    address: "0x7fc168e957ac87e2b7f9b7756452e478fe715cfb",
    reward: "0.000148115",
  },
  {
    address: "0xa8afbb77b7430b728f76e0aff1ee6c858e423499",
    reward: "0.000140034",
  },
  {
    address: "0x61d10bfda1aa5010795985fd9a49f21fb7570982",
    reward: "0.000133871",
  },
  {
    address: "0xaeb1a4ddda6ae9fa27f9bebb3e5e59b6f8567de0",
    reward: "0.00013386",
  },
  {
    address: "0xf3fb852a7a9486201b28311ba316721f04d2690e",
    reward: "0.00013295",
  },
  {
    address: "0xa3e2330e4fa9bb23d7eaaa3628b2c1906eead200",
    reward: "0.000124506",
  },
  {
    address: "0xa39bf151ff5ff87ae0c8c11a3f4220d10809dd66",
    reward: "0.000121749",
  },
  {
    address: "0x1530e79fe93209292321caaceeaa468c73157e11",
    reward: "0.000114675",
  },
  {
    address: "0x8e8f651efd439439eba920766e298959de505b2c",
    reward: "0.000113335",
  },
  {
    address: "0xfd53056b7aa6529ee7c316730d669b2596922e04",
    reward: "0.000111578",
  },
  {
    address: "0xbd3f90047b14e4f392d6877276d52d0ac59f4cf8",
    reward: "0.000111559",
  },
  {
    address: "0x0235639c9b6de98f087d9ef91847df80b5de622f",
    reward: "0.000102325",
  },
  {
    address: "0xb0559885be111a90cc4bb80603c3ed92c0b68c8c",
    reward: "0.000101401",
  },
  {
    address: "0xe87db83e9563161ae58daa9be62de5883959372f",
    reward: "0.000100715",
  },
  {
    address: "0x9638f59fa5edacaf3ce19d278f200fb339fe1bbc",
    reward: "0.00010041",
  },
  {
    address: "0x083bd503942b485455a704da2c173f991313abfb",
    reward: "0.000098004",
  },
  {
    address: "0x92697ec57d547bbd6c47e188b9d205880fa51e5d",
    reward: "0.000094991",
  },
  {
    address: "0x6d2a149fb8653b3a4ceadc213c991777240eccb2",
    reward: "0.000083379",
  },
  {
    address: "0xa4ca1b15fe81f57cb2d3f686c7b13309906cd37b",
    reward: "0.000074594",
  },
  {
    address: "0xdb7eaeb124253cc200eb44544cafcae66c37e250",
    reward: "0.000074076",
  },
  {
    address: "0xbf6b321d2291336e41fefc320eac5b569fa25421",
    reward: "0.000073898",
  },
  {
    address: "0x66e0fa6ec98670fab2f77583c209b2b7269de2db",
    reward: "0.000073791",
  },
  {
    address: "0xfaecae4464591f8f2025ba8acf58087953e613b1",
    reward: "0.000069845",
  },
  {
    address: "0x6dda8d7c1c5df90b3c00fc06de9188a80aab6980",
    reward: "0.000069454",
  },
  {
    address: "0x49cc19dbfe461fd20ab48e2d6ef73c7478b3ebdd",
    reward: "0.000067136",
  },
  {
    address: "0x2f7d973ae574af412af725a3f66099ae7714b125",
    reward: "0.000066585",
  },
  {
    address: "0x384f0cf645d9f9d1a83d3c0d6d9546532061b793",
    reward: "0.000063664",
  },
  {
    address: "0xf8f89e921af4d36d1f537745316cbfac30f63b3d",
    reward: "0.0000604",
  },
  {
    address: "0x957705f0302f70d34378f8c6a2d96f9a027ec33f",
    reward: "0.000057499",
  },
  {
    address: "0x5b5beebed201470d3864b835db6f96bbe84bb1ec",
    reward: "0.000053376",
  },
  {
    address: "0xc14fbb738ee2e196121b398858307a62987b9b40",
    reward: "0.000050889",
  },
  {
    address: "0x48b36fe754233c99cfb397dfa5a95d38274ced37",
    reward: "0.000037404",
  },
  {
    address: "0xf53a90daa7b688cbb87e92271407c77edbd0f511",
    reward: "0.000036511",
  },
  {
    address: "0xb2fd495b75dd3fb056658dd7910c79aadbda7a77",
    reward: "0.000033555",
  },
  {
    address: "0x737284cfc66fd5989f2ac866989d70ae134227cb",
    reward: "0.000028844",
  },
  {
    address: "0x595ffb4e0738f4976a82dc9cd5158ac1eecdebf1",
    reward: "0.000027947",
  },
  {
    address: "0x1f01c147e558be08414571a5a10597f754d6a2ce",
    reward: "0.000027309",
  },
  {
    address: "0xf162e1d5ab0671e9739c5a6c3d2cc850c9a34bcc",
    reward: "0.000025486",
  },
  {
    address: "0x4f56ecb7287651ae5379347c31b8c7ce329b5c11",
    reward: "0.000024543",
  },
  {
    address: "0xbecff511eb1f5889f07f79af7954c2271d5b4b78",
    reward: "0.000017137",
  },
  {
    address: "0x79a3c4563d8bb53d68524d26fcdd9cb54ed8f3c9",
    reward: "0.000015186",
  },
  {
    address: "0x9a6226ea0a4d87863763b0b98fb89f660aa19226",
    reward: "0.000014679",
  },
  {
    address: "0x4720d9395bc58369205f8e4710b57f5e131d8594",
    reward: "0.00001381",
  },
  {
    address: "0xd9e1d61d51b4d1ef7da8f09cabddcc59030bf872",
    reward: "0.000011324",
  },
  {
    address: "0x69df1f59a6c0fc50ee43ed5016d28f7cf3a6d69a",
    reward: "0.000010489",
  },
  {
    address: "0x7d964297869a22f9b116fe3f68c1090d4d708a77",
    reward: "0.000008954",
  },
  {
    address: "0xb1df150657e280dd4e170031b6884d27aeb8550d",
    reward: "0.000008429",
  },
  {
    address: "0x11ededebf63bef0ea2d2d071bdf88f71543ec6fb",
    reward: "0.000007612",
  },
  {
    address: "0xcf01158c05a113dfa04048b2f04eb3780ff220d7",
    reward: "0.000007178",
  },
  {
    address: "0xab0c9bc6bcbaad9391c530f33f9294dec38ae189",
    reward: "0.000007011",
  },
  {
    address: "0x8dae1879b022245f4527416206ffc87525f5e4c5",
    reward: "0.000005513",
  },
  {
    address: "0x70dc4c04f48a794964e97de7250e16f8d38b9a03",
    reward: "0.000004462",
  },
  {
    address: "0x4585560776923d96f50eef6b5863b3db0dcb1160",
    reward: "0.000003989",
  },
  {
    address: "0x67ae481d64fc8298da2aa8700a8afb03d580650c",
    reward: "0.000003878",
  },
  {
    address: "0xbd39feeb18083531d9572817e0c27c1487d39563",
    reward: "0.000003131",
  },
  {
    address: "0x7f62c3fe035f968e6b1f59447c0bffe3c28b6999",
    reward: "0.000002231",
  },
  {
    address: "0x432fcd67815d5cc72808a7815a02373fdee7d740",
    reward: "0.000002231",
  },
  {
    address: "0xd5d6927eacbc5ed42b7537f9f9af871ef6b38f30",
    reward: "0.00000079",
  },
  {
    address: "0x53e0dc522224e927a9813c0e38726ff37b3c7b43",
    reward: "0.000000112",
  },
  {
    address: "0xac0fe9f363c160c281c81ddc49d0aa8ce04c02eb",
    reward: "0",
  },
  {
    address: "0xa1f0aed05c063c201dcf63e28b19bd260d8561a8",
    reward: "0",
  },
];

const main = async () => {
  const getSafesAtStart: { owner: { id: string }; proxy: { id: string } }[] = await subgraphQueryPaginated(
    `{
        safes(where: {debt_gt: 0}, block: {number: 14967561}, skip: [[skip]], first: 1000) {
          owner {
            id
          }
          proxy {
            id
          }
        }
      }`,
    "safes",
    RAI_SUBGRAPH
  );

  console.log(`Found ${getSafesAtStart.length} safe at start`);

  const getSafeModifications: { safe: { owner: { id: string }; proxy: { id: string } } }[] =
    await subgraphQueryPaginated(
      `{
        modifySAFECollateralizations(where: {createdAtBlock_gt: 14967561, createdAtBlock_lt: 15147361}, skip: [[skip]], first: 1000) {
          safe {
            owner {
              id
            }
            proxy {
              id
            }
          }
        }
      }`,
      "modifySAFECollateralizations",
      RAI_SUBGRAPH
    );

  console.log(`Found ${getSafeModifications.length} safe modifications`);

  const eligibleAddresses = new Set();
  for (let e of getSafesAtStart) {
    eligibleAddresses.add(e.owner.id);
    if (e.proxy) eligibleAddresses.add(e.proxy.id);
  }

  for (let e of getSafeModifications) {
    eligibleAddresses.add(e.safe.owner.id);
    if (e.safe.proxy) eligibleAddresses.add(e.safe.proxy.id);
  }

  let eligibleARaiHolder: [string, number][] = [];
  for (let u of aRaiReward) {
    if (eligibleAddresses.has(u.address)) {
      eligibleARaiHolder.push([u.address, Number(u.reward)]);
    }
  }

  const total = eligibleARaiHolder.reduce((acc, curr) => acc + curr[1], 0);

  console.log(`Found ${eligibleARaiHolder.length} eligible aave minter for a total of ${total} of distro`);

  eligibleARaiHolder = eligibleARaiHolder.map((u) => [u[0], (u[1] / total) * REWARD_AMOUNT]);

  console.log(eligibleARaiHolder);

  const csv = eligibleARaiHolder.map((e) => `${e[0]},${e[1]}`).join("\n");
  fs.writeFileSync("aave-mint.csv", csv);
};

export const subgraphQueryPaginated = async (
  query: string,
  paginatedField: string,
  url: string
): Promise<any> => {
  const ret: any[] = [];
  let skip = 0;
  do {
    const paginatedQuery = query.replace("[[skip]]", skip.toString());
    const data = await subgraphQuery(paginatedQuery, url);

    ret.push(...data[paginatedField]);
    skip = data[paginatedField].length >= 1000 ? skip + 1000 : 0;
  } while (skip);

  return ret;
};

export const subgraphQuery = async (query: string, url: string): Promise<any> => {
  const prom = Axios.post(url, {
    query,
  });

  let resp: any;
  try {
    resp = await prom;
  } catch (err) {
    throw Error("Error with subgraph query: " + err);
  }

  if (!resp.data || !resp.data.data) {
    if (resp.data && resp.data.errors) {
      console.log(resp.data.errors);
    }

    throw Error("No data");
  }

  return resp.data.data;
};

main();
