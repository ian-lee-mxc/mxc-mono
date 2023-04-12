import { task } from "hardhat/config";

// @ts-ignore
import l1 from "../deployments/arb_goerli_L1.json";
task("deploy_L2").setAction(async (args, hre: any) => {
    await deployContracts(hre);
});

export async function deployContracts(hre: any) {
    const chainId = l1.chainId;
    const contractArtifacts = await hre.ethers.getContractFactory(
        "AddressManager"
    );
    const l2AddressManager = contractArtifacts.attach(
        "0x0000777700000000000000000000000000000006"
    );
    await l2AddressManager.setAddress(`${chainId}.mxc_header_sync`, l1.contracts.MXCL1);
    await l2AddressManager.setAddress(
        `${chainId}.mxc_token`,
        l1.contracts.MXCToken
    );
    await l2AddressManager.setAddress(`${chainId}.bridge`, l1.contracts.Bridge);
    await l2AddressManager.setAddress(
        `${chainId}.signal_service`,
        l1.contracts.SignalService
    );
    await l2AddressManager.setAddress(
        `${chainId}.token_vault`,
        l1.contracts.TokenVault
    );
}
