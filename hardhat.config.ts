import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "solidity-coverage";

import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.15",
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
    },
  },
  networks: {
    goerli: {
      url: process.env.GOERLI_URL || "",
      accounts: process.env.PRIVATE_KEY_DEPLOYER !== undefined ? [process.env.PRIVATE_KEY_DEPLOYER] : [],
    },
    mainnet: {
      url: process.env.MAINNET_URL || "",
      chainId: 1,
      accounts: process.env.PRIVATE_KEY_DEPLOYER !== undefined ? [process.env.PRIVATE_KEY_DEPLOYER] : [],
    },
    mumbai: {
      url: process.env.MUMBAI_URL || "",
      chainId: 80001,
      accounts: process.env.PRIVATE_KEY_DEPLOYER !== undefined ? [process.env.PRIVATE_KEY_DEPLOYER] : [],
    },
    polygon: {
      url: process.env.POLYGON_URL || "",
      chainId: 137,
      accounts: process.env.PRIVATE_KEY_DEPLOYER !== undefined ? [process.env.PRIVATE_KEY_DEPLOYER] : [],
    },
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_API_KEY || "",
      mainnet: process.env.ETHERSCAN_API_KEY || "",
    },
  },
};

export default config;
