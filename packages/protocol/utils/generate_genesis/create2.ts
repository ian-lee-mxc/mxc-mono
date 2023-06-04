import { ethers } from "ethers";
import { Result } from "./interface";
const path = require("path");
const ARTIFACTS_PATH = path.join(__dirname, "../../out");
const {
    computeStorageSlots,
    getStorageLayout,
} = require("@defi-wonderland/smock/dist/src/utils");

// deployCreate2 generates a L2 genesis alloc of an create2 contract,
export async function deployCreate2(
    config: any,
    result: Result
): Promise<Result> {
    const { contractOwner, chainId } = config;

    const alloc: any = {};
    const storageLayouts: any = {};

    const artifact = require(path.join(
        ARTIFACTS_PATH,
        "./Create2Factory.sol/Create2Factory.json"
    ));

    artifact.contractName = "Create2Factory";

    let address: string;
    if (
        config.contractAddresses &&
        ethers.utils.isAddress(config.contractAddresses[artifact.contractName])
    ) {
        address = config.contractAddresses[artifact.contractName];
    } else {
        address = ethers.utils.getCreate2Address(
            contractOwner,
            ethers.utils.keccak256(
                ethers.utils.toUtf8Bytes(`${chainId}${artifact.contractName}`)
            ),
            ethers.utils.keccak256(ethers.utils.toUtf8Bytes(artifact.bytecode))
        );
    }

    alloc[address] = {
        contractName: artifact.contractName,
        storage: {},
        code: artifact.deployedBytecode.object,
        balance: "0x0",
    };

    storageLayouts[artifact.contractName] = await getStorageLayout(
        artifact.contractName
    );

    for (const slot of computeStorageSlots(
        storageLayouts[artifact.contractName]
    )) {
        alloc[address].storage[slot.key] = slot.val;
    }

    result.alloc = Object.assign(result.alloc, alloc);
    result.storageLayouts = Object.assign(
        result.storageLayouts,
        storageLayouts
    );

    return result;
}
