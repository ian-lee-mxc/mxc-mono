import { expect } from "chai";
import { SimpleChannel } from "channel-ts";
import { BigNumber, ethers } from "ethers";
import { AddressManager, MXCL1, TestMXCToken } from "../../typechain";
import blockListener from "../utils/blockListener";
import { onNewL2Block } from "../utils/onNewL2Block";
import Proposer from "../utils/proposer";

import { initIntegrationFixture } from "../utils/fixture";
import sleep from "../utils/sleep";
import { deployMXCL1 } from "../utils/mxcL1";

describe("tokenomics: blockFee", function () {
    let mxcL1: MXCL1;
    let l2Provider: ethers.providers.JsonRpcProvider;
    let proposerSigner: any;
    let genesisHeight: number;
    let genesisHash: string;
    let mxcTokenL1: TestMXCToken;
    let l1AddressManager: AddressManager;
    let interval: any;
    let chan: SimpleChannel<number>;
    /* eslint-disable-next-line */
    let config: Awaited<ReturnType<MXCL1["getConfig"]>>;
    let proposer: Proposer;

    beforeEach(async () => {
        ({
            MXCL1: mxcL1,
            l2Provider,
            proposerSigner,
            genesisHeight,
            genesisHash,
            MXCTokenL1: mxcTokenL1,
            l1AddressManager,
            interval,
            chan,
            config,
            proposer,
        } = await initIntegrationFixture(true, true));
    });

    afterEach(() => clearInterval(interval));

    it("expects getBlockFee to return the initial feeBase at time of contract deployment", async function () {
        // deploy a new instance of MXCL1 so no blocks have passed.
        const tL1 = await deployMXCL1(l1AddressManager, genesisHash, true);
        const blockFee = await tL1.getBlockFee();
        expect(blockFee).to.be.eq(0);
    });

    it("block fee should increase as the halving period passes, while no blocks are proposed", async function () {
        const iterations: number = 5;
        const period: number = config.bootstrapDiscountHalvingPeriod
            .mul(1000)
            .toNumber();

        let lastBlockFee: BigNumber = await mxcL1.getBlockFee();

        for (let i = 0; i < iterations; i++) {
            await sleep(period);
            const blockFee = await mxcL1.getBlockFee();
            expect(blockFee).to.be.gt(lastBlockFee);
            lastBlockFee = blockFee;
        }
    });

    it(
        "proposes blocks on interval, proposer's balance for TkoToken should decrease as it pays proposer fee, " +
            "proofReward should increase since more slots are used and " +
            "no proofs have been submitted",
        async function () {
            // get the initial tkoBalance, which should decrease every block proposal
            let lastProposerBalance = await mxcTokenL1.balanceOf(
                await proposerSigner.getAddress()
            );

            let lastProofReward = BigNumber.from(0);

            // we want to wait for enough blocks until the blockFee is no longer 0, then run our
            // tests.
            while ((await mxcL1.getBlockFee()).eq(0)) {
                await sleep(500);
            }

            l2Provider.on("block", blockListener(chan, genesisHeight));
            /* eslint-disable-next-line */
            for await (const blockNumber of chan) {
                if (
                    blockNumber >
                    genesisHeight + (config.maxNumBlocks.toNumber() - 1)
                ) {
                    break;
                }
                const { newProposerBalance, newProofReward } =
                    await onNewL2Block(
                        l2Provider,
                        blockNumber,
                        proposer,
                        mxcL1,
                        proposerSigner,
                        mxcTokenL1
                    );

                console.log("lastProposerBalance", lastProposerBalance);
                console.log("newProposerBalance", newProposerBalance);

                expect(newProposerBalance).to.be.lt(lastProposerBalance);

                console.log("lastProofReward", lastProofReward);
                console.log("newProofReward", newProofReward);
                expect(newProofReward).to.be.gt(lastProofReward);

                lastProofReward = newProofReward;
                lastProposerBalance = newProposerBalance;
            }
        }
    );
});
