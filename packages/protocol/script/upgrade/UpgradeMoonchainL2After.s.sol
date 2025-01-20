// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/L1/TaikoL1.sol";
import "../../contracts/bridge/Bridge.sol";
import "../../contracts/mainnet/MainnetMoonchainL2.sol";
import "../../contracts/tokenvault/BridgedERC1155.sol";
import "../../contracts/tokenvault/BridgedERC20.sol";
import "../../contracts/tokenvault/BridgedERC20V2.sol";
import "../../contracts/tokenvault/BridgedERC721.sol";
import "../../contracts/tokenvault/ERC1155Vault.sol";
import "../../contracts/tokenvault/ERC20Vault.sol";
import "../../contracts/tokenvault/ERC721Vault.sol";
import "../../test/DeployCapability.sol";
import "./UpgradeScript.s.sol";
import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";
import { EthMxcPriceAggregator } from "../../contracts/bridge/EthMxcPriceAggregator.sol";
import { GenevaMoonchainL2 } from "../../contracts/mainnet/GenevaMoonchainL2.sol";
import { SignalService } from "../../contracts/signal/SignalService.sol";
import { TaikoL2 } from "../../contracts/L2/TaikoL2.sol";
import { ITransparentUpgradeableProxy } from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeMoonchainL2After is DeployCapability {
    address payable mxcL2 = payable(0x1000777700000000000000000000000000000001);
    uint256 ownerPrivateKey = vm.envUint("L2_OWNER_PRIVATE_KEY");
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address owner = vm.addr(ownerPrivateKey);
    uint256 L1_CHAIN_ID = vm.envUint("L1_CHAIN_ID");
    bool isMainnet = vm.envBool("IS_MAINNET");
    address L1_MXC_TOKEN = vm.envAddress("L1_MXC_TOKEN");
    uint256 ethMxcPrice = 500_000;

    address payable bridgeProxyAddr = payable(0x1000777700000000000000000000000000000003);

    address payable sharedAddressManagerProxyAddr =
        payable(0x2000777700000000000000000000000000000002);
    address payable rollupAddressManagerProxyAddr =
        payable(0x1000777700000000000000000000000000000006);
    address payable signalSericeProxyAddr = payable(0x1000777700000000000000000000000000000007);
    address public constant GOLDEN_TOUCH_ADDRESS = 0x0000777735367b36bC9B61C50022d9D0700dB4Ec;

    function getDeploymentJsonPath() public pure override returns (string memory) {
        return "/deployments/deploy_l2.json";
    }

    function run() external {
        vm.startBroadcast(ownerPrivateKey);

        // too large
        // Deploy Vaults
        deployProxy({
            name: "erc20_vault",
            impl: address(new ERC20Vault()),
            data: abi.encodeCall(ERC20Vault.init, (owner, sharedAddressManagerProxyAddr)),
            registerTo: sharedAddressManagerProxyAddr
        });

        deployProxy({
            name: "erc721_vault",
            impl: address(new ERC721Vault()),
            data: abi.encodeCall(ERC721Vault.init, (owner, sharedAddressManagerProxyAddr)),
            registerTo: sharedAddressManagerProxyAddr
        });

        deployProxy({
            name: "erc1155_vault",
            impl: address(new ERC1155Vault()),
            data: abi.encodeCall(ERC1155Vault.init, (owner, sharedAddressManagerProxyAddr)),
            registerTo: sharedAddressManagerProxyAddr
        });

        vm.stopBroadcast();
    }

    function addressNotNull(address addr, string memory err) private pure {
        require(addr != address(0), err);
    }

    function upgradeProxy(address payable proxy, address newImpl) public {
        vm.stopBroadcast();
        vm.startBroadcast(adminPrivateKey);
        ITransparentUpgradeableProxy(proxy).upgradeTo(newImpl);
        vm.stopBroadcast();
        vm.startBroadcast(ownerPrivateKey);
    }

    function upgradeProxyAndCall(
        address payable proxy,
        address newImpl,
        bytes memory data
    )
        public
    {
        vm.stopBroadcast();
        vm.startBroadcast(adminPrivateKey);
        ITransparentUpgradeableProxy(proxy).upgradeToAndCall(newImpl, data);
        vm.stopBroadcast();
        vm.startBroadcast(ownerPrivateKey);
    }

    //    function verifyMXCL2Slot() public {
    ////        bytes32 slot1 = readSlot(deployedMXCL2, 0);
    ////        uint8 _initialized = uint8(uint256(slot1));
    ////        assert(_initialized == uint8(1));
    //
    ////        bytes32 slot3 = readSlot(mxcL2, 0);
    ////        assert(_initialized == uint8(1));
    //    }
    //
    function readSlot(address _contract, uint256 _slot) internal view returns (bytes32 data) {
        data = vm.load(_contract, bytes32(uint256(_slot)));
        console2.log("----MXCL2 slot:", _slot, uint256(data));
        return data;
    }
}
