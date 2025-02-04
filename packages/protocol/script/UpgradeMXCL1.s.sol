// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../contracts/common/AddressManager.sol";
import "../contracts/L1/MxcL1.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../contracts/bridge/EtherVault.sol";
import "../contracts/bridge/TokenVault.sol";
import "../contracts/L1/MxcToken.sol";
import "../contracts/bridge/Bridge.sol";
import "../contracts/thirdparty/WETH9.sol";

contract UpgradeMXCL1 is Script {

    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    address payable public MXCL1 = payable(0x92a78e9D3DfcfDe54d59845248508CAa59fe6d4f);


    function run() external {
        vm.startBroadcast(privateKey);
        TransparentUpgradeableProxy(MXCL1).upgradeTo(address(new ProxiedMxcL1()));
        vm.stopBroadcast();

    }

}
