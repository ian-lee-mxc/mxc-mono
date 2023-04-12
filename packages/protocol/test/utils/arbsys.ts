import { ethers as hardhatEthers, network } from "hardhat";

const deployArbSys = async () => {
    await network.provider.send("hardhat_setCode", [
        "0x0000000000000000000000000000000000000064",
        (await hardhatEthers.getContractFactory("TestArbSys")).bytecode,
    ]);
};

export default deployArbSys;
