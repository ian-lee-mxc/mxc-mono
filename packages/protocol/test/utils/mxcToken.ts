import { ethers } from "ethers";
import { ethers as hardhatEthers } from "hardhat";
import { AddressManager } from "../../typechain";

const deployMXCToken = async (
    signer: ethers.Signer,
    addressManager: AddressManager,
    protoBroker: string
) => {
    const token = await (
        await hardhatEthers.getContractFactory("TestMXCToken")
    )
        .connect(signer)
        .deploy();
    await token.init("MXC Token", "MXC", addressManager.address);

    const network = await signer.provider?.getNetwork();

    await addressManager.setAddress(
        `${network?.chainId}.proto_broker`,
        protoBroker
    );

    return token;
};

export default deployMXCToken;
