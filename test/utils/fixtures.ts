import { ethers, getNamedAccounts } from "hardhat";
import { MultiSig, Counter } from "../../typechain-types";

export const deploy = async () => {
    const Ctr = await ethers.getContractFactory("Counter");

    const { alice, bob } = await getNamedAccounts();

    const counter = (await Ctr.deploy()) as unknown as Counter;

    const BAAI = await ethers.getContractFactory("MultiSig");
    const multiSig = (await BAAI.deploy(
        [alice, bob],
        2
    )) as unknown as MultiSig;

    return { counter, multiSig };
};
