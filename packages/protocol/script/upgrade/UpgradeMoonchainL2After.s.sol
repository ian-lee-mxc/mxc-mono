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
import { GenevaMoonchainL2 } from "../../contracts/mainnet/GenevaMoonchainL2.sol";
import "../../contracts/mainnet/MainnetMoonchainL2.sol";
import { EthMxcPriceAggregator } from "../../contracts/bridge/EthMxcPriceAggregator.sol";

contract UpgradeMoonchainL2After is DeployCapability {
    address payable mxcL2 = payable(0x1000777700000000000000000000000000000001);
    uint256 ownerPrivateKey = vm.envUint("L2_OWNER_PRIVATE_KEY");
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address owner = vm.addr(ownerPrivateKey);
    uint256 L1_CHAIN_ID = vm.envUint("L1_CHAIN_ID");
    bool isMainnet = vm.envBool("IS_MAINNET");
    address L1_MXC_TOKEN = vm.envAddress("L1_MXC_TOKEN");
    uint256 ethMxcPrice = 500_000;

    address payable sharedAddressManagerProxyAddr =
        payable(0x2000777700000000000000000000000000000002);
    address public constant GOLDEN_TOUCH_ADDRESS = 0x0000777735367b36bC9B61C50022d9D0700dB4Ec;

    function run() external {
        vm.startBroadcast(ownerPrivateKey);

        if (isMainnet) {
            MainnetMoonchainL2 taikoL2 = new MainnetMoonchainL2();
            upgradeProxy(mxcL2, address(taikoL2));
        } else {
            GenevaMoonchainL2 taikoL2 = new GenevaMoonchainL2();
            upgradeProxy(mxcL2, address(taikoL2));
        }
        // deploy eth mxc price aggregator
        //        console2.log(block.chainid,AddressManager(sharedAddressManagerProxyAddr).getAddress(uint64(block.chainid),
        // LibStrings.B_BRIDGE));

        register(
            sharedAddressManagerProxyAddr,
            "ethmxc_price_aggregator",
            address(new EthMxcPriceAggregator(int256(ethMxcPrice)))
        );

        //        register(sharedAddressManagerProxyAddr, "taiko_token", L1_MXC_TOKEN,
        // uint64(L1_CHAIN_ID));

        vm.stopBroadcast();
        //        TaikoData.BaseFeeConfig memory _baseFeeConfig = TaikoData.BaseFeeConfig({
        //            adjustmentQuotient: 8,
        //            sharingPctg: 75,
        //            gasIssuancePerSecond: 5_000_000,
        //            minGasExcess: 1_340_000_000, // correspond to 0.008847185 gwei basefee
        //            maxGasIssuancePerBlock: 600_000_000 // two minutes
        //        });
        //        console2.logBytes32(TaikoL2(mxcL2).publicInputHash());
        //        vm.roll(block.number + 1);
        //        console2.log("blockNumber", block.number, block.chainid);
        //        (bytes32 parentPublicInputHash,) =
        // TaikoL2(mxcL2)._calcPublicInputHash(block.number + 1);
        //        console2.logBytes32(parentPublicInputHash);
        //        vm.startPrank(GOLDEN_TOUCH_ADDRESS);
        //
        //        TaikoL2(mxcL2).anchorV2(
        //            uint64(block.number + 1),
        //            bytes32(uint256(1)),
        //            uint32(0),
        //            _baseFeeConfig
        //        );
        //        vm.stopPrank();
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
