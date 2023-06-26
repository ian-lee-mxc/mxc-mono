// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "../contracts/L1/MxcToken.sol";
import "../contracts/common/AddressManager.sol";



contract DeployMxcToken is Script {
    using SafeCastUpgradeable for uint256;

    uint256 public deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    address public owner = vm.envAddress("OWNER");

    address public addressManagerProxy;

    address public mxcTokenPremintRecipient = vm.envAddress("MXC_TOKEN_PREMINT_RECIPIENT");

    uint256 public mxcTokenPremintAmount = vm.envUint("MXC_TOKEN_PREMINT_AMOUNT");


    function run() external {
        require(owner != address(0), "owner is zero");
        require(mxcTokenPremintRecipient != address(0), "mxcTokenPremintRecipient is zero");
        require(mxcTokenPremintAmount < type(uint256).max, "premint too large");

        vm.startBroadcast();

        AddressManager addressManager = new ProxiedAddressManager();
        addressManagerProxy = deployProxy(
            "address_manager", address(addressManager), bytes.concat(addressManager.init.selector)
        );
        // MxcToken
        MxcToken mxcToken = new ProxiedMxcTokenProd();

        address[] memory premintRecipients = new address[](1);
        uint256[] memory premintAmounts = new uint256[](1);
        premintRecipients[0] = mxcTokenPremintRecipient;
        premintAmounts[0] = mxcTokenPremintAmount;

        deployProxy(
            "mxc_token",
            address(mxcToken),
            bytes.concat(
                mxcToken.init.selector,
                abi.encode(
                    addressManagerProxy, "MXC Token", "MXC", premintRecipients, premintAmounts
                )
            )
        );
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
