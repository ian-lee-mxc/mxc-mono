// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";
import "../../contracts/L1/TaikoL1.sol";
import "./UpgradeScript.s.sol";
import {TaikoL2} from "../../contracts/L2/TaikoL2.sol";
import "../../test/DeployCapability.sol";
import {SignalService} from "../../contracts/signal/SignalService.sol";
import {TransparentUpgradeableProxy} from "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../../contracts/bridge/Bridge.sol";
import "../../contracts/tokenvault/ERC20Vault.sol";
import "../../contracts/tokenvault/ERC721Vault.sol";
import "../../contracts/tokenvault/ERC1155Vault.sol";
import "../../contracts/tokenvault/BridgedERC20.sol";
import "../../contracts/tokenvault/BridgedERC721.sol";
import "../../contracts/tokenvault/BridgedERC1155.sol";

contract UpgradeTaikoL2 is DeployCapability {

    address payable mxcL2 = payable(0x1000777700000000000000000000000000000001);
    address payable rollupAddressManagerProxyAddr = payable(0x1000777700000000000000000000000000000002);
    address payable sharedAddressManagerProxyAddr = payable(0x2000777700000000000000000000000000000003);
    address payable signalSericeProxyAddr = payable(0x2000777700000000000000000000000000000004);
    address payable bridgeProxyAddr = payable(0x2000777700000000000000000000000000000005);
    uint256 ownerPrivateKey = vm.envUint("L2_OWNER_PRIVATE_KEY");
    uint256 L1_CHAIN_ID = vm.envUint("L1_CHAIN_ID");
    uint256 gasExcess = vm.envUint("GAS_EXCESS");
    address owner = vm.addr(ownerPrivateKey);
    function run() external {

        TaikoL2 taikoL2 = new TaikoL2();

        deployAddressManagerContracts();
        TransparentUpgradeableProxy(mxcL2).upgradeTo(address(taikoL2));
        TaikoL2(mxcL2).doMigrate(owner, rollupAddressManagerProxyAddr,  uint64(L1_CHAIN_ID), uint64(gasExcess));

    }

    function deployAddressManagerContracts() internal  {
        addressNotNull(owner, "owner");

        AddressManager rollupAddressManager = new AddressManager();
        TransparentUpgradeableProxy(rollupAddressManagerProxyAddr).upgradeTo(address(rollupAddressManager));
        AddressManager(rollupAddressManagerProxyAddr).init(owner);

        AddressManager sharedAddressManager = new AddressManager();
        TransparentUpgradeableProxy(sharedAddressManagerProxyAddr).upgradeTo(address(sharedAddressManager));
        AddressManager(sharedAddressManagerProxyAddr).init(owner);


        TransparentUpgradeableProxy(signalSericeProxyAddr).upgradeTo(address(new SignalService()));
        SignalService(signalSericeProxyAddr).init(owner, sharedAddressManagerProxyAddr);
        register(sharedAddressManagerProxyAddr, "signal_service",  signalSericeProxyAddr);

        // Deploy Bridging contracts

        TransparentUpgradeableProxy(bridgeProxyAddr).upgradeTo(address(new Bridge()));
        Bridge(payable(bridgeProxyAddr)).init(owner, sharedAddressManagerProxyAddr);
        register(sharedAddressManagerProxyAddr, "bridge", bridgeProxyAddr);

        if (vm.envBool("PAUSE_BRIDGE")) {
            Bridge(payable(bridgeProxyAddr)).pause();
        }

        Bridge(payable(bridgeProxyAddr)).transferOwnership(owner);

        console2.log("------------------------------------------");
        console2.log(
            "Warning - you need to register *all* counterparty bridges to enable multi-hop bridging:"
        );
        console2.log(
            "sharedAddressManager.setAddress(remoteChainId, \"bridge\", address(remoteBridge))"
        );
        console2.log("- sharedAddressManager : ", sharedAddressManagerProxyAddr);

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

        console2.log("------------------------------------------");
        console2.log(
            "Warning - you need to register *all* counterparty vaults to enable multi-hop bridging:"
        );
        console2.log(
            "sharedAddressManager.setAddress(remoteChainId, \"erc20_vault\", address(remoteERC20Vault))"
        );
        console2.log(
            "sharedAddressManager.setAddress(remoteChainId, \"erc721_vault\", address(remoteERC721Vault))"
        );
        console2.log(
            "sharedAddressManager.setAddress(remoteChainId, \"erc1155_vault\", address(remoteERC1155Vault))"
        );
        console2.log("- sharedAddressManager : ", sharedAddressManagerProxyAddr);

        register(rollupAddressManagerProxyAddr, "taiko", address(mxcL2));
        register(rollupAddressManagerProxyAddr, "bridge", address(bridgeProxyAddr));
        register(rollupAddressManagerProxyAddr, "signal_service", address(signalSericeProxyAddr));

        // Deploy Bridged token implementations
        register(sharedAddressManagerProxyAddr, "bridged_erc20", address(new BridgedERC20()));
        register(sharedAddressManagerProxyAddr, "bridged_erc721", address(new BridgedERC721()));
        register(sharedAddressManagerProxyAddr, "bridged_erc1155", address(new BridgedERC1155()));
    }

    function addressNotNull(address addr, string memory err) private pure {
        require(addr != address(0), err);
    }


//    function verifyMXCL2Slot() public {
////        bytes32 slot1 = readSlot(deployedMXCL2, 0);
////        uint8 _initialized = uint8(uint256(slot1));
////        assert(_initialized == uint8(1));
//
////        bytes32 slot3 = readSlot(mxcL2, 0);
////        address _owner = address(uint160(uint256(slot3)));
////        assert(_initialized == uint8(1));
//    }
//
//    function readSlot(address _contract, uint256 _slot) internal view returns (bytes32 data) {
//        data = vm.load(_contract, bytes32(uint256(_slot)));
//        console2.log("----MXCL2 slot:", _slot, uint256(data));
//        return data;
//    }
}
