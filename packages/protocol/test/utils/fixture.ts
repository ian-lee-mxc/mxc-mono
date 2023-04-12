import { SimpleChannel } from "channel-ts";
import { ethers } from "ethers";
import deployAddressManager from "./addressManager";
import Proposer from "./proposer";
import Prover from "./prover";
import {
    getDefaultL1Signer,
    getDefaultL2Signer,
    getL1Provider,
    getL2Provider,
} from "./provider";
import { createAndSeedWallets, sendTinyEtherToZeroAddress } from "./seed";
import { defaultFeeBase, deployMXCL1 } from "./mxcL1";
import { deployMXCL2 } from "./mxcL2";
import deployMXCToken from "./mxcToken";
import deployArbSys from "./arbsys";

async function initIntegrationFixture(
    mintTkoToProposer: boolean,
    enableTokenomics: boolean = true
) {
    const l1Provider = getL1Provider();

    l1Provider.pollingInterval = 100;

    const l1Signer = await getDefaultL1Signer();

    const l2Provider = getL2Provider();

    l2Provider.pollingInterval = 100;

    const l2Signer = await getDefaultL2Signer();

    // When connecting to a geth node, we need to unlock the account manually, and
    // we can safely ignore the unlock error when connecting to a hardhat node.
    try {
        await Promise.all([l1Signer.unlock(""), l2Signer.unlock("")]);
    } catch (_) {}

    await deployArbSys();
    const l2AddressManager = await deployAddressManager(l2Signer);
    const MXCL2 = await deployMXCL2(
        l2Signer,
        l2AddressManager,
        false,
        5000000 // Note: need to explicitly set gasLimit here, otherwise the deployment transaction may fail.
    );
    const MXCL2DeployReceipt = await MXCL2.deployTransaction.wait();

    const genesisHash = MXCL2DeployReceipt.blockHash as string;
    const genesisHeight = MXCL2DeployReceipt.blockNumber as number;

    const l1AddressManager = await deployAddressManager(l1Signer);
    const MXCL1 = await deployMXCL1(
        l1AddressManager,
        genesisHash,
        enableTokenomics,
        defaultFeeBase
    );
    const { chainId } = await l1Provider.getNetwork();

    const [proposerSigner, proverSigner] = await createAndSeedWallets(
        2,
        l1Signer
    );

    const MXCTokenL1 = await deployMXCToken(
        l1Signer,
        l1AddressManager,
        MXCL1.address
    );

    await (
        await l1AddressManager.setAddress(
            `${chainId}.mxc_token`,
            MXCTokenL1.address
        )
    ).wait(1);

    const { chainId: l2ChainId } = await l2Provider.getNetwork();

    await (
        await l1AddressManager.setAddress(`${l2ChainId}.MXC`, MXCL2.address)
    ).wait(1);

    await (
        await l1AddressManager.setAddress(
            `${chainId}.proof_verifier`,
            MXCL1.address
        )
    ).wait(1);

    if (mintTkoToProposer) {
        const mintTx = await MXCTokenL1.connect(l1Signer).mintAnyone(
            await proposerSigner.getAddress(),
            ethers.utils.parseEther("100")
        );

        await mintTx.wait(1);
    }

    // send transactions to L1 so we always get new blocks
    const interval = setInterval(
        async () => await sendTinyEtherToZeroAddress(l1Signer),
        1 * 1000
    );

    // send transactions to L2 so we always get new blocks (replaces evm_setAutomine?)
    const interval2 = setInterval(
        async () => await sendTinyEtherToZeroAddress(l2Signer),
        1 * 1000
    );

    const tx = await l2Signer.sendTransaction({
        to: proverSigner.address,
        value: ethers.utils.parseUnits("1", "ether"),
    });
    await tx.wait(1);

    const chan = new SimpleChannel<number>();
    const config = await MXCL1.getConfig();

    const proposer = new Proposer(
        MXCL1.connect(proposerSigner),
        l2Provider,
        config.commitConfirmations.toNumber(),
        config.maxNumBlocks.toNumber(),
        0,
        proposerSigner
    );

    const prover = new Prover(MXCL1, l2Provider, proverSigner);
    return {
        MXCL1,
        MXCL2,
        l1Provider,
        l2Provider,
        l1Signer,
        l2Signer,
        proposerSigner,
        proverSigner,
        genesisHeight,
        genesisHash,
        MXCTokenL1,
        l1AddressManager,
        interval,
        interval2,
        chan,
        config,
        proposer,
        prover,
    };
}

export { initIntegrationFixture };
