import { ethers, getNamedAccounts } from "hardhat";

import { MultiSig, Counter } from "../typechain-types";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { deploy } from "./utils/fixtures";

describe("BAAIMultiSig", () => {
    let counter: Counter, multiSig: MultiSig;

    beforeEach(async () => {
        const obj = await loadFixture(deploy);

        counter = obj.counter;
        multiSig = obj.multiSig;

        await counter.addAllowed(multiSig.target);
    });

    it(".. should test multisig called by owner", async () => {
        const { alice } = await getNamedAccounts();
        const signer = await ethers.getSigner(alice);
        const data = counter
            .connect(signer)
            .interface.encodeFunctionData("update");

        await multiSig.submit(counter.target, data);

        expect(await counter.counter()).to.equal(1);
    });

    it(".. should test multisig called by signers", async () => {
        const { alice, bob } = await getNamedAccounts();
        const aliceSigner = await ethers.getSigner(alice);
        const bobSigner = await ethers.getSigner(bob);
        const data = counter.interface.encodeFunctionData("update");

        await multiSig.connect(aliceSigner).submit(counter.target, data);
        // proposa Id will be 0
        await multiSig.connect(bobSigner).approve(0);

        expect(await counter.counter()).to.equal(1);
    });
});
