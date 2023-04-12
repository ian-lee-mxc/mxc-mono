import { task } from "hardhat/config";
import sleep from "../test/utils/sleep";

task("mock_transaction_L2").setAction(async (args, hre: any) => {
    await mockTransactionL2(hre);
});

export async function mockTransactionL2(hre: any) {
    const [signer] = await hre.ethers.getSigners();
    while (true) {
        try {
            await signer.sendTransaction({
                to: "0x7029B4B9A3d20029323FadD1Ae77Bb57c9BF70d6",
                value: 1,
            });
        } catch (e) {
            console.log(e);
        }
    }
}
