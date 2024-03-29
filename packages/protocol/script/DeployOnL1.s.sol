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
import "../contracts/L1/MxcL1.sol";
import "../contracts/bridge/Bridge.sol";
import "../contracts/bridge/TokenVault.sol";
import "../contracts/bridge/EtherVault.sol";
import "../contracts/signal/SignalService.sol";
import "../contracts/common/AddressManager.sol";
import "../contracts/test/erc20/FreeMintERC20.sol";
import "../contracts/test/erc20/MayFailFreeMintERC20.sol";
import "../test/LibLn.sol";
import "../contracts/thirdparty/WETH9.sol";
import "../contracts/common/EthMxcPriceAggregator.sol";

interface ArbSys {
    /**
     * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
     * @return block number as int
     */
    function arbBlockNumber() external view returns (uint256);

    function arbBlockHash(uint256 blockNumber) external view returns (bytes32);
}

contract ArbSysTest is ArbSys {
    /**
     * @notice Get Arbitrum block number (distinct from L1 block number; Arbitrum genesis block has block number 0)
     * @return block number as int
     */
    function arbBlockNumber() external view returns (uint256) {
        return block.number;
    }

    function arbBlockHash(uint256 blockNumber) external view returns (bytes32) {
        return blockhash(blockNumber);
    }
}

contract Verifier {
    fallback(bytes calldata) external returns (bytes memory) {
        return bytes.concat(keccak256("mxczkevm"));
    }
}

contract DeployOnL1 is Script {
    using SafeCastUpgradeable for uint256;

    bytes32 public genesisHash = vm.envBytes32("L2_GENESIS_HASH");

    uint256 public deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    address public mxcL2Address = vm.envAddress("MXC_L2_ADDRESS");

    address public l2SignalService = vm.envAddress("L2_SIGNAL_SERVICE");

    address public owner = vm.envAddress("OWNER");

    address public relayer = vm.envAddress("RELAYER");

    address public oracleProver = vm.envAddress("ORACLE_PROVER");
    address public systemProver = vm.envAddress("SYSTEM_PROVER");

    address public sharedSignalService = vm.envAddress("SHARED_SIGNAL_SERVICE");

    address public treasury = vm.envAddress("TREASURY");

    address public mxcTokenPremintRecipient = vm.envAddress("MXC_TOKEN_PREMINT_RECIPIENT");
//
    uint256 public mxcTokenPremintAmount = vm.envUint("MXC_TOKEN_PREMINT_AMOUNT");

//    address public deployedMxcTokenAddress = vm.envAddress("MXC_TOKEN_ADDRESS");

    // Change it based on 'consensus' / experience / expected result
    // Based in seconds. Please set carefully.
    // For testnet it could be somewhere 85-100s
    // For mainnet it could be around 1800 s (30mins)
    // Can be adjusted later with setters
    uint64 public INITIAL_PROOF_TIME_TARGET = uint64(vm.envUint("INITIAL_PROOF_TIME_TARGET")); // 160s
    uint16 public ADJUSTMENT_QUOTIENT = uint16(vm.envUint("ADJUSTMENT_QUOTIENT")); // 32000

    MxcL1 mxcL1;
    address public addressManagerProxy;

    error FAILED_TO_DEPLOY_PLONK_VERIFIER(string contractPath);
    error PROOF_TIME_TARGET_NOT_SET();

    function run() external {
        require(owner != address(0), "owner is zero");
        require(mxcL2Address != address(0), "mxcL2Address is zero");
        require(l2SignalService != address(0), "l2SignalService is zero");
        require(treasury != address(0), "treasury is zero");
        require(mxcTokenPremintRecipient != address(0), "mxcTokenPremintRecipient is zero");
        require(mxcTokenPremintAmount < type(uint256).max, "premint too large");

        console2.log("owner",owner);
        deployArbSysTest();
        vm.startBroadcast(deployerPrivateKey);

        // AddressManager
        AddressManager addressManager = new ProxiedAddressManager();
        addressManagerProxy = deployProxy(
            "address_manager", address(addressManager), bytes.concat(addressManager.init.selector)
        );

        // MxcL1
        MxcL1 mxcL1Implement = new ProxiedMxcL1();
        uint256 l2ChainId = mxcL1Implement.getConfig().chainId;
        require(l2ChainId != block.chainid, "same chainid");

        setAddress(l2ChainId, "mxczkevm", mxcL2Address);
        setAddress(l2ChainId, "signal_service", l2SignalService);
        setAddress("oracle_prover", oracleProver);
        setAddress("system_prover", systemProver);
        setAddress(l2ChainId, "treasury", treasury);

        // MxcToken
        MxcToken mxcToken = new ProxiedMxcToken();

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

        // Ride Token && Park Token
        address rideToken = address(new FreeMintERC20("Ride Token", "RIDE"));
        console2.log("Ride Token", rideToken);

        address parkToken = address(new FreeMintERC20("Park Token", "PARK"));
        console2.log("Park Token", parkToken);

        uint64 feeBase = uint64(1) ** 8;

        // Calculating it for our needs based on testnet/mainnet. We need it in
        // order to make the fees on the same level - in ideal circumstences.
        // See Brecht's comment https://github.com/taikoxyz/taiko-mono/pull/13564
        if (INITIAL_PROOF_TIME_TARGET == 0) {
            revert PROOF_TIME_TARGET_NOT_SET();
        }

        uint64 initProofTimeIssued = LibLn.calcInitProofTimeIssued(
            feeBase, uint16(INITIAL_PROOF_TIME_TARGET), uint16(ADJUSTMENT_QUOTIENT)
        );

        address mxcL1Proxy = deployProxy(
            "mxczkevm",
            address(mxcL1Implement),
            bytes.concat(
                mxcL1Implement.init.selector,
                abi.encode(
                    addressManagerProxy,
                    genesisHash,
                    feeBase,
                    INITIAL_PROOF_TIME_TARGET,
                    initProofTimeIssued,
                    uint16(ADJUSTMENT_QUOTIENT)
                )
            )
        );
        mxcL1 = MxcL1(payable(mxcL1Proxy));
        setAddress("proto_broker", mxcL1Proxy);

        // Bridge
        Bridge bridge = new ProxiedBridge();
        deployProxy(
            "bridge",
            address(bridge),
            bytes.concat(bridge.init.selector, abi.encode(addressManagerProxy))
        );

        // TokenVault
        TokenVault tokenVault = new ProxiedTokenVault();
        deployProxy(
            "token_vault",
            address(tokenVault),
            bytes.concat(tokenVault.init.selector, abi.encode(addressManagerProxy))
        );

        // SignalService
        if (sharedSignalService == address(0)) {
            SignalService signalService = new ProxiedSignalService();
            deployProxy(
                "signal_service",
                address(signalService),
                bytes.concat(signalService.init.selector, abi.encode(addressManagerProxy))
            );
        } else {
            console2.log("Warining: using shared signal service: ", sharedSignalService);
            setAddress("signal_service", sharedSignalService);
        }

        setAddress(mxcL1.getVerifierName(100), address(new Verifier()));
        setAddress(mxcL1.getVerifierName(0), address(new Verifier()));

        WETH9 weth = new WETH9();
        deployProxy(
            "weth",
            address(weth),
            ""
        );
        EtherVault etherVault = new ProxiedEtherVault();
        deployProxy(
            "ether_vault",
            address(etherVault),
            bytes.concat(etherVault.init.selector, abi.encode(addressManagerProxy))
        );

        EthMxcPriceAggregator ethMxcPriceAggregator = new EthMxcPriceAggregator();
        int price = 90000;
        deployProxy(
            "oracle_ethmxc",
            address(ethMxcPriceAggregator),
            bytes.concat(ethMxcPriceAggregator.init.selector, abi.encode(addressManagerProxy, price))
        );
        setAddress("relayer", address(relayer));
//        setAddress("weth", address(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1));

        setAddress(l2ChainId, "bridge", address(0x1000777700000000000000000000000000000004));
        setAddress(l2ChainId, "ether_vault", address(0x1000777700000000000000000000000000000003));
        setAddress(l2ChainId, "token_vault", address(0x1000777700000000000000000000000000000002));

        // PlonkVerifier
        deployPlonkVerifiers();

        vm.stopBroadcast();
    }

    function deployArbSysTest() internal {
        ArbSys arbSysTest = new ArbSysTest();
        vm.etch(address(100), address(arbSysTest).code);
        console2.log(ArbSys(arbSysTest).arbBlockNumber());
    }

    function deployPlonkVerifiers() private {
        address[] memory plonkVerifiers = new address[](1);
        plonkVerifiers[0] = deployYulContract("contracts/libs/yul/PlonkVerifier.yulp");

        for (uint16 i = 0; i < plonkVerifiers.length; ++i) {
            setAddress(mxcL1.getVerifierName(i), plonkVerifiers[i]);
        }
    }

    function deployYulContract(string memory contractPath) private returns (address) {
        string[] memory cmds = new string[](3);
        cmds[0] = "bash";
        cmds[1] = "-c";
        cmds[2] = string.concat(
            vm.projectRoot(),
            "/bin/solc --yul --bin ",
            string.concat(vm.projectRoot(), "/", contractPath),
            " | grep -A1 Binary | tail -1"
        );

        bytes memory bytecode = vm.ffi(cmds);

        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        if (deployedAddress == address(0)) {
            revert FAILED_TO_DEPLOY_PLONK_VERIFIER(contractPath);
        }

        console2.log(contractPath, deployedAddress);

        return deployedAddress;
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
        console2.log(chainId, string(abi.encodePacked(name)), "--->", addr);
        if (addr != address(0)) {
            AddressManager(addressManagerProxy).setAddress(chainId, name, addr);
        }
    }
}
