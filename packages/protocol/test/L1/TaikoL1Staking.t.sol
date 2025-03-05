// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TaikoL1TestBase.sol";
import { MxcToken } from "../../contracts/tko/MxcToken.sol";
import { GenevaMoonchainL1 } from "../../contracts/mainnet/GenevaMoonchainL1.sol";
import {L1Staking} from "../../contracts/team/staking/L1Staking.sol";

contract Verifier {
    fallback(bytes calldata) external returns (bytes memory) {
        return bytes.concat(keccak256("taiko"));
    }
}

contract TaikoL1StakingTest is TaikoL1TestBase {
    MxcToken public mxcToken;
    GenevaMoonchainL1 public mL1;
    L1Staking public l1Staking;

    function setUp() public override {
        vm.warp(1_730_132_788);
        mine(100_000_000);
        super.setUp();
        mL1.initMigrate(msg.sender, address(addressManager), bytes32(uint256(1)), mL1.getConfig().ontakeForkHeight, false);
        tko = TaikoToken(
            deployProxy({
                name: "taiko_token",
                impl: address(new MxcToken()),
                data: abi.encodeCall(
                    MxcToken.init2, (address(addressManager), address(this), address(0), address(this))
                ),
                registerTo: address(addressManager)
            })
        );
        l1Staking = L1Staking(
            deployProxy({
                name: "staking",
                impl: address(new L1Staking()),
                data: abi.encodeCall(
                    L1Staking.init, (address(this), address(addressManager))
                ),
                registerTo: address(addressManager)
            })
        );

        mxcToken = MxcToken(address(tko));
        mxcToken.transfer(Alice, 10_000_000 * 1 ether);
        mxcToken.transfer(Bob, 10_000_000 * 1 ether);
    }

    function deployTaikoL1() internal override returns (TaikoL1 taikoL1) {
        taikoL1 = TaikoL1(
            payable(
                deployProxy({ name: "taiko", impl: address(new GenevaMoonchainL1()), data: "" })
            )
        );
        mL1 = GenevaMoonchainL1(address(taikoL1));
    }

    function test_L1_StakingAndReward() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(Alice,6_000_000 * 1 ether);
        l1Staking.stake(Alice,1_000_000 * 1 ether);

        uint256 totalBalance;
        uint256 totalReward;

        (uint256 balance,,) = l1Staking.stakingUserState(Alice);
        assertEq(balance, 7_000_000 * 1 ether);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();
        assertEq(totalBalance, 7_000_000 * 1 ether);

        vm.startPrank(Bob);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(Bob,6_000_000 * 1 ether);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();
        assertEq(totalBalance, (7_000_000 + 6_000_000) * 1 ether);

        proposeBlockV2(msg.sender, 0);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();
        console2.log(
            "rewardDebt",
            l1Staking.stakingCalculateRewardDebt(Alice),
            l1Staking.stakingCalculateRewardDebt(Bob),
            totalReward
        );
        vm.warp(block.timestamp + 12);
        proposeBlockV2(msg.sender, 0);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();

        console2.log(
            "rewardDebt",
            l1Staking.stakingCalculateRewardDebt(Alice),
            l1Staking.stakingCalculateRewardDebt(Bob),
            totalReward
        );
        vm.warp(block.timestamp + 24);
        proposeBlockV2(msg.sender, 0);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();
        console2.log(
            "rewardDebt",
            l1Staking.stakingCalculateRewardDebt(Alice),
            l1Staking.stakingCalculateRewardDebt(Bob),
            totalReward
        );
    }

    function test_L1_StakingShouldRevert() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        vm.expectRevert(L1Staking.INSUFFICIENT_DEPOSIT.selector);
        l1Staking.stake(Alice,1_000_000 * 1 ether - 1);
    }

    function test_L1_Withdraw() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(Alice,1_000_000 * 1 ether);

        vm.expectRevert(L1Staking.WITHDRAWAL_LOCKED.selector);
        l1Staking.stakingWithdrawal();

        l1Staking.stakingRequestWithdrawal(false);
        vm.warp(block.timestamp + l1Staking.WITHDRAWAL_LOCK_EPOCH() * 7 days);
        uint256 beforeBalance = mxcToken.balanceOf(Alice);
        l1Staking.stakingWithdrawal();
        assertEq(mxcToken.balanceOf(Alice), beforeBalance + 1_000_000 * 1 ether);

        vm.expectRevert(L1Staking.INSUFFICIENT_BALANCE.selector);
        l1Staking.stakingWithdrawal();
    }

    function test_L1_Slashing() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(Alice,1_000_000 * 1 ether);

        vm.stopPrank();
        (uint256 totalBalanceBefore,,,,,) = l1Staking.stakingState();
        l1Staking.stakingSlashing(Alice, 10);

        (uint256 balance,,) = l1Staking.stakingUserState(Alice);
        assertEq(balance, 1_000_000 * 1 ether - (1_000_000 * 1 ether / 10));
        (uint256 totalBalanceAfter,,,,,) = l1Staking.stakingState();

        assertEq(totalBalanceBefore, totalBalanceAfter + (1_000_000 * 1 ether / 10));
    }

    function test_L1_stakingFirstWeekRewardEmpty() external {
        vm.warp(block.timestamp + 1000);
        proposeBlockV2(msg.sender, 0);
        vm.warp(block.timestamp + 1000);
        proposeBlockV2(msg.sender, 0);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(Alice, 5_000_000 * 1 ether);

        (,uint256 totalReward,,,,) = l1Staking.stakingState();

        console2.log("Total rewards:", totalReward);
        assertGt(totalReward, 0);

        assertEq(l1Staking.stakingCalculateRewardDebt(Alice),0);
        vm.warp(block.timestamp + 7 days);
        assertGt(l1Staking.stakingCalculateRewardDebt(Alice), 0);
    }

    function test_L1_StakingRewardDistribution() external {
        // 设置初始账户余额
        address[] memory stakers = new address[](6);
        stakers[0] = Alice;   // 已有1000万
        stakers[1] = Bob;     // 已有1000万
        stakers[2] = address(0x3);
        stakers[3] = address(0x4);
        stakers[4] = address(0x5);
        stakers[5] = address(0x6);
    
        console2.log("totalSupply",mxcToken.totalSupply());
        // 给新账户转账
        for(uint i = 2; i < stakers.length; i++) {
            mxcToken.transfer(stakers[i], 10_000_000 * 1 ether);
        }
        
        // 生成区块并等待一段时间来累积奖励
        vm.warp(block.timestamp + 30 days);
        proposeBlockV2(msg.sender, 0);
        vm.warp(block.timestamp + 7 days);
        proposeBlockV2(msg.sender, 0);

        vm.warp(block.timestamp + 7 days);
        proposeBlockV2(msg.sender, 0);
        vm.warp(block.timestamp + 7 days);
        proposeBlockV2(msg.sender, 0);
    
        // 测试场景1: 单个质押者
        vm.startPrank(stakers[0]);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(stakers[0], 5_000_000 * 1 ether);

        vm.warp(block.timestamp + 7 days);
        proposeBlockV2(msg.sender, 0);

        
        uint256 reward1 = l1Staking.stakingCalculateRewardDebt(stakers[0]);
        console2.log("Single staker reward after :", reward1);

    
        // 测试场景2: 三个质押者，不同质押金额
        vm.startPrank(stakers[1]);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(stakers[1], 3_000_000 * 1 ether);
    
        vm.startPrank(stakers[2]);
        mxcToken.approve(address(l1Staking), type(uint256).max);
        l1Staking.stake(stakers[2], 2_000_000 * 1 ether);
    
        vm.warp(block.timestamp + 7 days);
        proposeBlockV2(msg.sender, 0);
    
        uint256 reward2_1 = l1Staking.stakingCalculateRewardDebt(stakers[0]);
        uint256 reward2_2 = l1Staking.stakingCalculateRewardDebt(stakers[1]);
        uint256 reward2_3 = l1Staking.stakingCalculateRewardDebt(stakers[2]);
    
        console2.log("Three stakers rewards after 7days:");
        console2.log("Staker1 (5M staked):", reward2_1);
        console2.log("Staker2 (3M staked):", reward2_2);
        console2.log("Staker3 (2M staked):", reward2_3);
    
        // 6 staker
        for(uint i = 3; i < stakers.length; i++) {
            vm.startPrank(stakers[i]);
            mxcToken.approve(address(l1Staking), type(uint256).max);
            l1Staking.stake(stakers[i], 1_000_000 * 1 ether);
        }
        vm.warp(block.timestamp + 7 days);
        proposeBlockV2(msg.sender, 0);
    
        uint totalClaimedAmount;
        uint totalReward;
        for(uint epoch = 0 ; epoch < 100; epoch++) {
            if(epoch % 2 == 0) {
                vm.warp(block.timestamp + 7 days);
                console2.log("7 days");
            } else {
                vm.warp(block.timestamp + 30 days);
                console2.log("30 days");
            }
            proposeBlockV2(msg.sender, 0);

            // verify claim again after 1 epoch
            for(uint i = 0; i < stakers.length; i++) {
                uint256 beforeBalance = mxcToken.balanceOf(stakers[i]);
                // uint256 reward = l1Staking.stakingCalculateRewardDebt(stakers[i]);
                // console2.log(string.concat("Staker", vm.toString(i + 1)), ":", reward);
                vm.prank(stakers[i]);
                l1Staking.stakingClaimReward();
                totalClaimedAmount += mxcToken.balanceOf(stakers[i]) - beforeBalance;
            }
            // verify total
            (,totalReward,,,,) = l1Staking.stakingState();
            console2.log("Total rewards:", totalReward);
            console2.log("Total claimedAmount:", totalClaimedAmount);
            assertGt(totalReward, 0);
            assertGt(totalReward, totalClaimedAmount); 
        }
    }
}
