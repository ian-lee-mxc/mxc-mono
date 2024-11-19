// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";
import "../../contracts/L1/TaikoL1.sol";
import "./UpgradeScript.s.sol";
import { TaikoL2 } from "../../contracts/L2/TaikoL2.sol";
import "../../test/DeployCapability.sol";
import { SignalService } from "../../contracts/signal/SignalService.sol";
import { TransparentUpgradeableProxy } from
    "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../../contracts/bridge/Bridge.sol";
import "../../contracts/tokenvault/ERC20Vault.sol";
import "../../contracts/tokenvault/ERC721Vault.sol";
import "../../contracts/tokenvault/ERC1155Vault.sol";
import "../../contracts/tokenvault/BridgedERC20.sol";
import "../../contracts/tokenvault/BridgedERC721.sol";
import "../../contracts/tokenvault/BridgedERC1155.sol";
import "../../contracts/mainnet/GenevaMoonchainL2.sol";
import "../../contracts/mainnet/MainnetMoonchainL2.sol";
import { EthMxcPriceAggregator } from "../../contracts/bridge/EthMxcPriceAggregator.sol";

contract UpgradeMoonchainL2 is DeployCapability {
    address payable mxcL2 = payable(0x1000777700000000000000000000000000000001);
    address payable sharedAddressManagerProxyAddr =
        payable(0x2000777700000000000000000000000000000002);
    address payable bridgeProxyAddr = payable(0x1000777700000000000000000000000000000003);
    address payable rollupAddressManagerProxyAddr =
        payable(0x1000777700000000000000000000000000000006);
    address payable signalSericeProxyAddr = payable(0x1000777700000000000000000000000000000007);
    uint256 ownerPrivateKey = vm.envUint("L2_OWNER_PRIVATE_KEY");
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    uint256 L1_CHAIN_ID = vm.envUint("L1_CHAIN_ID");
    uint256 gasExcess = vm.envUint("GAS_EXCESS");
    address owner = vm.addr(ownerPrivateKey);
    bool isMainnet = vm.envBool("IS_MAINNET");

    address public constant GOLDEN_TOUCH_ADDRESS = 0x0000777735367b36bC9B61C50022d9D0700dB4Ec;

    function run() external {
        require(adminPrivateKey != 0, "invalid priv key");
        vm.startBroadcast(ownerPrivateKey);
        //        deployAddressManagerContracts();

        if (isMainnet) {
            console2.log("isMainnet");
            MainnetMoonchainL2 taikoL2 = new MainnetMoonchainL2();
            bytes memory data = abi.encodeCall(
                GenevaMoonchainL2.initMoonchain,
                (owner, rollupAddressManagerProxyAddr, uint64(L1_CHAIN_ID), uint64(gasExcess))
            );
            upgradeProxyAndCall(mxcL2, address(taikoL2), data);
        } else {
            console2.log("geneva testnet");
            GenevaMoonchainL2 taikoL2 = new GenevaMoonchainL2();
            bytes memory data = abi.encodeCall(
                GenevaMoonchainL2.initMoonchain,
                (owner, rollupAddressManagerProxyAddr, uint64(L1_CHAIN_ID), uint64(gasExcess))
            );
            upgradeProxyAndCall(mxcL2, address(taikoL2), data);
        }

        vm.stopBroadcast();

        console2.logBytes32(TaikoL2(mxcL2).publicInputHash());
        vm.roll(block.number + 1);
        console2.log("blockNumber", block.number + 1, block.chainid);
        vm.startPrank(GOLDEN_TOUCH_ADDRESS);
        TaikoData.BaseFeeConfig memory _baseFeeConfig = TaikoData.BaseFeeConfig({
            adjustmentQuotient: 8,
            sharingPctg: 75,
            gasIssuancePerSecond: 5_000_000,
            minGasExcess: 1_340_000_000, // correspond to 0.008847185 gwei basefee
            maxGasIssuancePerBlock: 600_000_000 // two minutes
         });
        TaikoL2(mxcL2).anchorV2(uint64(block.number + 1), bytes32(uint256(1)), 0, _baseFeeConfig);
        vm.stopPrank();
    }

    function deployAddressManagerContracts() internal {
        addressNotNull(owner, "owner");

        AddressManager rollupAddressManager = new AddressManager();
        upgradeProxy(rollupAddressManagerProxyAddr, address(rollupAddressManager));
        AddressManager(rollupAddressManagerProxyAddr).init2(owner);

        AddressManager sharedAddressManager = new AddressManager();
        upgradeProxy(sharedAddressManagerProxyAddr, address(sharedAddressManager));
        AddressManager(sharedAddressManagerProxyAddr).init(owner);

        upgradeProxy(signalSericeProxyAddr, address(new SignalService()));
        SignalService(signalSericeProxyAddr).init2(owner, sharedAddressManagerProxyAddr);
        register(sharedAddressManagerProxyAddr, "signal_service", signalSericeProxyAddr);

        // Deploy Bridging contracts
        upgradeProxyAndCall(
            bridgeProxyAddr,
            address(new Bridge()),
            abi.encodeCall(Bridge.forkInit, (owner, sharedAddressManagerProxyAddr))
        );
        register(sharedAddressManagerProxyAddr, "bridge", bridgeProxyAddr);

        if (vm.envBool("PAUSE_BRIDGE")) {
            Bridge(payable(bridgeProxyAddr)).pause();
        }
        //
        //        Bridge(payable(bridgeProxyAddr)).transferOwnership(owner);

        console2.log("------------------------------------------");
        console2.log(
            "Warning - you need to register *all* counterparty bridges to enable multi-hop bridging:"
        );
        console2.log(
            "sharedAddressManager.setAddress(remoteChainId, \"bridge\", address(remoteBridge))"
        );
        console2.log("- sharedAddressManager : ", sharedAddressManagerProxyAddr);

        // Deploy Vaults
        //        deployProxy({
        //            name: "erc20_vault",
        //            impl: address(new ERC20Vault()),
        //            data: abi.encodeCall(ERC20Vault.init, (owner, sharedAddressManagerProxyAddr)),
        //            registerTo: sharedAddressManagerProxyAddr
        //        });
        //
        //        deployProxy({
        //            name: "erc721_vault",
        //            impl: address(new ERC721Vault()),
        //            data: abi.encodeCall(ERC721Vault.init, (owner,
        // sharedAddressManagerProxyAddr)),
        //            registerTo: sharedAddressManagerProxyAddr
        //        });
        //
        //        deployProxy({
        //            name: "erc1155_vault",
        //            impl: address(new ERC1155Vault()),
        //            data: abi.encodeCall(ERC1155Vault.init, (owner,
        // sharedAddressManagerProxyAddr)),
        //            registerTo: sharedAddressManagerProxyAddr
        //        });

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

    function upgradeProxy(address payable proxy, address newImpl) public {
        vm.stopBroadcast();
        vm.startBroadcast(adminPrivateKey);
        TransparentUpgradeableProxy(proxy).upgradeTo(newImpl);
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
        TransparentUpgradeableProxy(proxy).upgradeToAndCall(newImpl, data);
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
