// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../contracts/common/AddressManager.sol";
import "../contracts/L1/MxcL1.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../contracts/bridge/EtherVault.sol";


contract SetBridgeAddress is Script {

    uint256 public deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    address public owner = vm.envAddress("OWNER");

    address public addressManagerProxy;

    MxcL1 mxcL1;

    function run() external {
        string memory deployL1Json = vm.readFile(string.concat(vm.projectRoot(), "/deployments/deploy_l1.json"));
        AddressManager addressManager = new ProxiedAddressManager();
        mxcL1 = new ProxiedMxcL1();
        uint256 l2ChainId = mxcL1.getConfig().chainId;
        console2.log(deployL1Json);
        console2.log("chainId", block.chainid);

        address bridgeAddr = vm.parseJsonAddress(deployL1Json, ".bridge");
        address tokenVaultAddr = vm.parseJsonAddress(deployL1Json, ".token_vault");
        address mxcTokenAddr = vm.parseJsonAddress(deployL1Json, ".mxc_token");
        address headerSyncAddr = vm.parseJsonAddress(deployL1Json, ".mxczkevm");
        address signalServiceAddr = vm.parseJsonAddress(deployL1Json, ".signal_service");



        if(l2ChainId == block.chainid) {

            vm.etch(address(0x1000777700000000000000000000000000000006),address(addressManager).code);
            vm.startBroadcast(deployerPrivateKey);

            setAddress(421613, "mxczkevm", headerSyncAddr);
            setAddress(421613, "bridge", bridgeAddr);
            setAddress(421613, "token_vault", tokenVaultAddr);
            setAddress(421613, "mxc_token", mxcTokenAddr);
            setAddress(421613, "signal_service", signalServiceAddr);
        }else {
            addressManagerProxy = vm.parseJsonAddress(deployL1Json, ".address_manager");
            vm.etch(addressManagerProxy, address(addressManager).code);
            vm.startBroadcast(deployerPrivateKey);

            EtherVault etherVault = new ProxiedEtherVault();
            deployProxy(
                "ether_vault",
                address(etherVault),
                bytes.concat(etherVault.init.selector, abi.encode(addressManagerProxy))
            );

            setAddress(l2ChainId, "bridge", address(0x1000777700000000000000000000000000000004));
            setAddress(l2ChainId, "ether_vault", address(0x1000777700000000000000000000000000000002));
            setAddress(l2ChainId, "token_vault", address(0x1000777700000000000000000000000000000003));
        }
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

        vm.writeJson(
            vm.serializeAddress("deployment", name, proxy),
            string.concat(vm.projectRoot(), "/deployments/deploy_l1.json")
        );
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
