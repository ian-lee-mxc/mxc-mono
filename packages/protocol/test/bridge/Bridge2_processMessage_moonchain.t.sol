// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Bridge2.t.sol";
import { EthMxcPriceAggregator } from "../../contracts/bridge/EthMxcPriceAggregator.sol";

contract Target is IMessageInvocable {
    uint256 public receivedEther;
    IBridge private bridge;
    IBridge.Context public ctx;

    constructor(IBridge _bridge) {
        bridge = _bridge;
    }

    function onMessageInvocation(bytes calldata) external payable {
        ctx = bridge.context();
        receivedEther += msg.value;
    }

    function anotherFunc(bytes calldata) external payable {
        receivedEther += msg.value;
    }

    fallback() external payable {
        ctx = bridge.context();
        receivedEther += msg.value;
    }

    receive() external payable { }
}

contract OutOfQuotaManager is IQuotaManager {
    function consumeQuota(address, uint256) external pure {
        revert("out of quota");
    }
}

contract AlwaysAvailableQuotaManager is IQuotaManager {
    function consumeQuota(address, uint256) external pure { }
}

contract BridgeTest2_processMessage_moonchain is TaikoTest {
    bytes public constant fakeProof = "";

    address public owner;
    uint64 public remoteChainId;
    address public remoteBridge;

    AddressManager public addressManager;
    SignalService public signalService;
    Bridge public bridge;

    uint256 public ethMxcPrice = 500_000;

    modifier transactedBy(address addr) {
        vm.deal(addr, 100 ether);
        vm.startPrank(addr);

        _;
        vm.stopPrank();
    }

    modifier dealEther(address addr) {
        vm.deal(addr, 100 ether);
        _;
    }

    uint64 constant CHAIN_ID_GENEVA = 5_167_003;
    uint64 constant CHAIN_ID_ARBITRUM = 42_161;

    function setUp() public {
        owner = vm.addr(0x1000);
        vm.deal(owner, 100 ether);
        vm.chainId(uint256(CHAIN_ID_ARBITRUM));
        remoteChainId = uint64(CHAIN_ID_GENEVA);
        remoteBridge = vm.addr(0x2000);

        vm.startPrank(owner);

        addressManager = AddressManager(
            deployProxy({
                name: "address_manager",
                impl: address(new AddressManager()),
                data: abi.encodeCall(AddressManager.init, (address(0)))
            })
        );

        signalService = SkipProofCheckSignal(
            deployProxy({
                name: "signal_service",
                impl: address(new SkipProofCheckSignal()),
                data: abi.encodeCall(SignalService.init, (address(0), address(addressManager))),
                registerTo: address(addressManager)
            })
        );
        addressManager.setAddress(remoteChainId, "signal_service", address(signalService));

        bridge = Bridge(
            payable(
                deployProxy({
                    name: "bridge",
                    impl: address(new Bridge()),
                    data: abi.encodeCall(Bridge.init, (address(0), address(addressManager))),
                    registerTo: address(addressManager)
                })
            )
        );

        address ethMxcPriceAggregator = deployProxy({
            name: "ethmxc_price_aggregator",
            impl: address(new EthMxcPriceAggregator()),
            data: abi.encodeCall(EthMxcPriceAggregator.init, (int256(ethMxcPrice))),
            registerTo: address(addressManager)
        });
        addressManager.setAddress(
            remoteChainId, "ethmxc_price_aggregator", address(ethMxcPriceAggregator)
        );
        vm.deal(address(bridge), 10_000 ether);

        addressManager.setAddress(remoteChainId, "bridge", remoteBridge);
        vm.stopPrank();
    }

    function test_bridge2_processMessage_with_relayer_eth_mxc_price_transform_from_moonchain()
        public
        dealEther(Alice)
        dealEther(Bob)
    {
        IBridge.Message memory message;
        vm.chainId(uint256(CHAIN_ID_ARBITRUM));

        // message from Geneva to Arbitrum
        message.srcChainId = CHAIN_ID_GENEVA;
        message.destChainId = CHAIN_ID_ARBITRUM;

        message.gasLimit = 6_000_000;
        message.fee = 100 ether;
        message.value = 0;
        message.destOwner = Alice;
        message.to = David;

        uint256 BobBalanceBefore = Bob.balance;
        uint256 AliceBalanceBefore = Alice.balance;
        vm.prank(Bob);
        bridge.processMessage(message, fakeProof);

        assertEq(
            Bob.balance - BobBalanceBefore + Alice.balance - AliceBalanceBefore,
            message.fee / ethMxcPrice
        );
    }

    function test_bridge2_processMessage_with_relayer_eth_mxc_price_transform_to_moonchain()
        public
        dealEther(Alice)
        dealEther(Bob)
    {
        IBridge.Message memory message;

        vm.chainId(uint256(CHAIN_ID_GENEVA));

        // message from Geneva to Arbitrum
        message.srcChainId = CHAIN_ID_ARBITRUM;
        message.destChainId = CHAIN_ID_GENEVA;

        message.gasLimit = 1_000_000;
        message.fee = 0.01 ether;
        message.value = 0;
        message.destOwner = Alice;
        message.to = David;

        uint256 BobBalanceBefore = Bob.balance;
        uint256 AliceBalanceBefore = Alice.balance;
        vm.prank(Bob);
        bridge.processMessage(message, fakeProof);

        assertEq(
            Bob.balance - BobBalanceBefore + Alice.balance - AliceBalanceBefore,
            message.fee * ethMxcPrice
        );
    }
}
