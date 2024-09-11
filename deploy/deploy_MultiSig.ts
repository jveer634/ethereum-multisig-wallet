import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;

    const { deployer, alice, bob } = await getNamedAccounts();

    await deployments.deploy("MultiSig", {
        from: deployer,
        args: [[alice, bob], 2],
    });
};
export default func;

func.tags = ["MultiSig"];
