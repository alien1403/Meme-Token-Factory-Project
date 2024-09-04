require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

const deployerPrivateKey =
  process.env.DEPLOYER_PRIVATE_KEY ??
  "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
// If not set, it uses ours Etherscan default API key.
const etherscanApiKey =
  process.env.ETHERSCAN_API_KEY || "DNXJA8RX2Q3VZ4URQIWP7Z68CJXQZSC6AW";
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.ETHEREUM_MAINNET_RPC_URL,
      },
    },
    sepolia: {
      url: process.env.ETHEREUM_SEPOLIA_RPC_URL,
      accounts: [deployerPrivateKey],
      gas: 3000000, // Set a higher gas limit if necessary
      gasPrice: 20000000000,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: etherscanApiKey,
    },
  },
};
