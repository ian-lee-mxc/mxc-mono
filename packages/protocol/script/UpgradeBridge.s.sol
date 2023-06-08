// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../contracts/common/AddressManager.sol";
import "../contracts/L1/MxcL1.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../contracts/bridge/EtherVault.sol";
import "../contracts/L1/MxcToken.sol";
import "../contracts/bridge/Bridge.sol";


contract UpgradeBridge is Script {

    uint256 public deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    uint256 public ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");

    address payable bridgeAddress;

    function run() external {
        string memory deployL1Json = vm.readFile(string.concat(vm.projectRoot(), "/deployments/deploy_l1.json"));
        uint256 l2ChainId = 5167003;

        if(l2ChainId == block.chainid) {
            vm.startBroadcast(deployerPrivateKey);
            bridgeAddress = payable(0x1000777700000000000000000000000000000004);

        }else {
            vm.startBroadcast(ownerPrivateKey);
            bridgeAddress = payable(vm.parseJsonAddress(deployL1Json, ".bridge"));
        }
        ProxiedBridge newBridge = new ProxiedBridge();
        TransparentUpgradeableProxy(bridgeAddress).upgradeTo(address(newBridge));
        vm.stopBroadcast();

    }
}
