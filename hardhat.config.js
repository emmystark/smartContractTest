require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.0", // Matches NFTMarketplace.sol pragma in pragma
  networks: {
    hardhat: {},
    sepolia: {
      url: process.env.QUICKNODE_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};