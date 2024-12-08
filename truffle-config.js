const ganache = require("ganache");
require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    development: {
      provider: ganache.provider({
        quiet: true,
        chain: {
          hardfork: "grayGlacier",
        },
      }),
      host: "localhost",
      port: 8545,
      network_id: "*",
    },
    sepolia: {
      provider: () =>
        new HDWalletProvider(
          process.env.MNEMONIC || process.env.PRIVATE_KEY,
          `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`
        ),
      network_id: 11155111,
      chain_id: 11155111,
      gas: 5500000,
      gasPrice: 20000000000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      networkCheckTimeout: 10000,
      verify: {
        apiUrl: "https://api-sepolia.etherscan.io",
        apiKey: process.env.ETHERSCAN_API_KEY,
      },
    },
    "base-sepolia": {
      provider: () =>
        new HDWalletProvider({
          mnemonic: {
            phrase: process.env.MNEMONIC || process.env.PRIVATE_KEY,
          },
          providerOrUrl: "https://sepolia.base.org",
          pollingInterval: 8000,
          networkCheckTimeout: 100000,
          timeoutBlocks: 200,
        }),
      network_id: 84532,
      chain_id: 84532,
      gas: 5500000,
      gasPrice: 20000000000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      networkCheckTimeout: 10000,
      verify: {
        apiUrl: "https://api-sepolia.basescan.org",
        apiKey: process.env.BASESCAN_API_KEY,
      },
    },
    "zkevm-cardona": {
      provider: () =>
        new HDWalletProvider({
          mnemonic: {
            phrase: process.env.MNEMONIC || process.env.PRIVATE_KEY,
          },
          providerOrUrl: "https://rpc.cardona.zkevm-rpc.com",
          pollingInterval: 8000,
          networkCheckTimeout: 100000,
          timeoutBlocks: 200,
        }),
      network_id: 2442,
      chain_id: 2442,
      gas: 5500000,
      gasPrice: 20000000000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      networkCheckTimeout: 10000,
      verify: {
        apiUrl: "https://cardona-zkevm.polygonscan.com",
        apiKey: process.env.POLYGONSCAN_API_KEY,
      },
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  before: (done) => {
    if (process.env.NODE_ENV !== "production") {
      ganache.server().listen(8545, done);
    } else {
      done();
    }
  },
  after: (done) => {
    if (process.env.NODE_ENV !== "production") {
      ganache.server().close(done);
    } else {
      done();
    }
  },
};
