import { ethers } from "ethers";
import { ethers as hardhatEthers } from "hardhat";
import { AddressManager, MXCL2 } from "../../typechain";

async function deployMXCL2(
    signer: ethers.Signer,
    addressManager: AddressManager,
    enablePublicInputsCheck: boolean = true,
    gasLimit: number | undefined = undefined
): Promise<MXCL2> {
    // Deploying MXCL2 Contract linked with LibTxDecoder (throws error otherwise)
    const l2LibTxDecoder = await (
        await hardhatEthers.getContractFactory("LibTxDecoder")
    )
        .connect(signer)
        .deploy();

    const MXCL2 = await (
        await hardhatEthers.getContractFactory(
            enablePublicInputsCheck
                ? "TestMXCL2EnablePublicInputsCheck"
                : "TestMXCL2",
            {
                libraries: {
                    LibTxDecoder: l2LibTxDecoder.address,
                },
            }
        )
    )
        .connect(signer)
        .deploy(addressManager.address, { gasLimit });

    return MXCL2 as MXCL2;
}

export { deployMXCL2 };
