<<<<<<< Updated upstream
require("@nomiclabs/hardhat-ethers");
require('solidity-coverage')
=======
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require('solidity-coverage');
>>>>>>> Stashed changes

const RINKEBY_RPC_URL = process.env.rinkebyInfuraAPIKey
const PRIVATE_KEY = process.env.devTestnetPrivateKey

module.exports = {
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {
    },
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: [PRIVATE_KEY]
    }
  },
  solidity: {
    compilers: [{version: "0.8.0"},
    {version: "0.8.7"},
    {version: "0.8.10"},
    {version: "0.6.6"}],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 3000000
  }
}
