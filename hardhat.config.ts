import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "hardhat-deploy";
import "hardhat-deploy-ethers";

import "dotenv/config";

const config: HardhatUserConfig = {
    solidity: "0.8.20",

    namedAccounts: {
        deployer: 0,
        alice: 1,
        bob: 2,
    },

    networks: {
        arbitrumTest: {
            url: process.env.RPC as string,
            accounts: [
                process.env.USER1 as string,
                process.env.USER2 as string,
                process.env.USER3 as string,
            ],
        },
    },
};

export default config;
