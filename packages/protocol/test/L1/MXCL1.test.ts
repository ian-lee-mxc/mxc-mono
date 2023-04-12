import { expect } from "chai";
import { ethers } from "hardhat";
import { MXCL1 } from "../../typechain";
import deployAddressManager from "../utils/addressManager";
import { randomBytes32 } from "../utils/bytes";
import { deployMXCL1 } from "../utils/mxcL1";
import deployArbSys from "../utils/arbsys";

describe("MXCL1", function () {
    let MXCL1: MXCL1;
    let genesisHash: string;

    beforeEach(async function () {
        const l1Signer = (await ethers.getSigners())[0];
        await deployArbSys();
        const addressManager = await deployAddressManager(l1Signer);
        genesisHash = randomBytes32();
        MXCL1 = await deployMXCL1(addressManager, genesisHash, false);
    });

    describe("getLatestSyncedHeader()", async function () {
        it("should be genesisHash because no headers have been synced", async function () {
            const hash = await MXCL1.getLatestSyncedHeader();
            expect(hash).to.be.eq(genesisHash);
        });
    });

    describe("getSyncedHeader()", async function () {
        it("should revert because header number has not been synced", async function () {
            await expect(MXCL1.getSyncedHeader(1)).to.be.revertedWith(
                "L1_BLOCK_NUMBER()"
            );
        });

        it("should return appropraite hash for header", async function () {
            const hash = await MXCL1.getSyncedHeader(0);
            expect(hash).to.be.eq(genesisHash);
        });
    });

    describe("proposeBlock()", async function () {
        it("should revert when size of inputs is les than 2", async function () {
            await expect(
                MXCL1.proposeBlock([randomBytes32()])
            ).to.be.revertedWith("L1_INPUT_SIZE()");
        });
    });

    describe("commitBlock()", async function () {
        it("should revert when size of inputs is les than 2", async function () {
            await expect(
                MXCL1.proposeBlock([randomBytes32()])
            ).to.be.revertedWith("L1_INPUT_SIZE()");
        });
    });
});
