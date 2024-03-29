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


contract UpgradeBridge is Script {

    uint256 public deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    uint256 public ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");

    address public owner = vm.envAddress("OWNER");

    address public addressManagerProxy;

    address payable bridgeAddress;

    address payable tokenVaultAddress;



    function run() external {
        string memory deployL1Json = vm.readFile(string.concat(vm.projectRoot(), "/deployments/deploy_l1.json"));
        uint256 l2ChainId = 5167004;

        if(l2ChainId == block.chainid) {
            vm.startBroadcast(deployerPrivateKey);
            addressManagerProxy = address(0x1000777700000000000000000000000000000006);
            bridgeAddress = payable(0x1000777700000000000000000000000000000004);
            tokenVaultAddress = payable(0x1000777700000000000000000000000000000002);
        }else {
            vm.startBroadcast(ownerPrivateKey);
            addressManagerProxy = vm.parseJsonAddress(deployL1Json, ".address_manager");
            bridgeAddress = payable(vm.parseJsonAddress(deployL1Json, ".bridge"));
            tokenVaultAddress = payable(vm.parseJsonAddress(deployL1Json, ".token_vault"));
        }

//        setAddress("weth",address(0x343788cd13Fb71a3DE3E6a2149D880c29F7A3E75));
        ProxiedBridge newBridge = new ProxiedBridge();
        TransparentUpgradeableProxy(bridgeAddress).upgradeTo(address(newBridge));
//
//        ProxiedTokenVault newTokenVault = new ProxiedTokenVault();
//        TransparentUpgradeableProxy(tokenVaultAddress).upgradeTo(address(newTokenVault));

        vm.stopBroadcast();

    }

    function deployProxy(string memory name, address implementation, bytes memory data)
    private
    returns (address proxy)
    {
        proxy = address(new TransparentUpgradeableProxy(implementation, owner, data));

        console2.log(name, "(impl) ->", implementation);
        console2.log(name, "(proxy) ->", proxy);

        if (addressManagerProxy != address(0)) {
            setAddress(block.chainid, bytes32(bytes(name)), proxy);
        }

//        vm.writeJson(
//            vm.serializeAddress("deployment", name, proxy),
//            string.concat(vm.projectRoot(), "/deployments/deploy_l1.json")
//        );
    }

    function setAddress(bytes32 name, address addr) private {
        setAddress(block.chainid, name, addr);
    }

    function setAddress(uint256 chainId, bytes32 name, address addr) private {
        console2.log(chainId, uint256(name), "--->", addr);
        if (addr != address(0)) {
            AddressManager(addressManagerProxy).setAddress(chainId, name, addr);
        }
    }
}
