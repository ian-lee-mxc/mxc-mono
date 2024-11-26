// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../contracts/tokenvault/BridgedERC20V2.sol";
import "./UpgradeScript.s.sol";

import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";
import { AddressManager } from "../../contracts/common/AddressManager.sol";
import { DeployCapability } from "../../test/DeployCapability.sol";
import { GenevaMoonchainL1 } from "../../contracts/mainnet/GenevaMoonchainL1.sol";
import { TransparentUpgradeableProxy } from
    "../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { Bridge } from "../../contracts/bridge/Bridge.sol";
import { ERC20Vault } from "../../contracts/tokenvault/ERC20Vault.sol";

contract UpgradeGenevaMoonchainL1 is DeployCapability {
    function run() external {
        address HARDCODE_MXC_NATIVE_TOKEN_ADDR = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        address sharedAddressManager = address(0x5E453d54F7783446bb206B261A4bffb24859512f);
        address rollupAddressManager = address(0x8687d9034D4e6A12d2F91DB6FF27fb2cab5979D9);
        address TAIKO_L2_ADDRESS = address(0x1000777700000000000000000000000000000001);
        address L2_SIGNAL_SERVICE = address(0x1000777700000000000000000000000000000006); // rollup
            // signal
        address TAIKO_L1_ADDRESS = address(0x6a5c9E342d5FB5f5EF8a799f0cAAB2678C939b0B);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        upgradeProxy(payable(TAIKO_L1_ADDRESS), address(new GenevaMoonchainL1()));

        GenevaMoonchainL1 taikoL1 = GenevaMoonchainL1(TAIKO_L1_ADDRESS);
        register(sharedAddressManager, "bridged_erc20", address(new BridgedERC20V2()));
        register(sharedAddressManager, "erc20_vault", address(new ERC20Vault()));
        register(sharedAddressManager, "bridge", address(new Bridge()));
        copyRegister(rollupAddressManager, sharedAddressManager, "bridge");

        vm.stopBroadcast();
    }

    function upgradeProxy(address payable proxy, address newImpl) public {
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("ADMIN_KEY"));
        TransparentUpgradeableProxy(proxy).upgradeTo(newImpl);
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
    }

    function upgradeProxyAndCall(
        address payable proxy,
        address newImpl,
        bytes memory data
    )
        public
    {
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("ADMIN_KEY"));
        TransparentUpgradeableProxy(proxy).upgradeToAndCall(newImpl, data);
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
    }
}
