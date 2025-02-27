require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    base_sepolia: {
      url: process.env.BASE_TESTNET_RPC,
      accounts: [process.env.PRIVATE_KEY || ""]
    }
  }
}; 