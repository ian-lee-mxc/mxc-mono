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
        super.setUp();
        console2.log("addressManager", address(addressManager));
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

        proposeBlock(msg.sender, 0);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();
        console2.log(
            "rewardDebt",
            l1Staking.stakingCalculateRewardDebt(Alice),
            l1Staking.stakingCalculateRewardDebt(Bob),
            totalReward
        );
        vm.warp(block.timestamp + 12);
        proposeBlock(msg.sender, 0);
        (totalBalance, totalReward,,,,) = l1Staking.stakingState();

        console2.log(
            "rewardDebt",
            l1Staking.stakingCalculateRewardDebt(Alice),
            l1Staking.stakingCalculateRewardDebt(Bob),
            totalReward
        );
        vm.warp(block.timestamp + 24);
        proposeBlock(msg.sender, 0);
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
}
