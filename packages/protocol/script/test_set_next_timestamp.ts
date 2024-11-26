import { ethers } from "ethers";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");

provider.send("evm_increaseTime", [3600]).then((r) => {
    console.log("evm_increaseTime success");
    provider.send("hardhat_mine", ["0x1"]);
});
