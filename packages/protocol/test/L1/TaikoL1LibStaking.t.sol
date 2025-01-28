// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TaikoL1TestBase.sol";
import { MxcToken } from "../../contracts/tko/MxcToken.sol";
import { GenevaMoonchainL1 } from "../../contracts/mainnet/GenevaMoonchainL1.sol";
import { LibStaking } from "../../contracts/L1/libs/LibStaking.sol";

contract Verifier {
    fallback(bytes calldata) external returns (bytes memory) {
        return bytes.concat(keccak256("taiko"));
    }
}

contract TaikoL1LibStakingTest is TaikoL1TestBase {
    MxcToken public mxcToken;
    GenevaMoonchainL1 public mL1;

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
        mxcToken.approve(address(mL1), type(uint256).max);
        mL1.stake(Alice,6_000_000 * 1 ether);
        mL1.stake(Alice,1_000_000 * 1 ether);

        uint256 totalBalance;
        uint256 totalReward;

        (uint256 balance,,) = mL1.stakingUserState(Alice);
        assertEq(balance, 7_000_000 * 1 ether);
        (totalBalance, totalReward,,,,) = mL1.stakingState();
        assertEq(totalBalance, 7_000_000 * 1 ether);

        vm.startPrank(Bob);
        mxcToken.approve(address(mL1), type(uint256).max);
        mL1.stake(Bob,6_000_000 * 1 ether);
        (totalBalance, totalReward,,,,) = mL1.stakingState();
        assertEq(totalBalance, (7_000_000 + 6_000_000) * 1 ether);

        mL1.stakingDepositReward();
        (totalBalance, totalReward,,,,) = mL1.stakingState();
        console2.log(
            "rewardDebt",
            mL1.stakingCalculateRewardDebt(Alice),
            mL1.stakingCalculateRewardDebt(Bob),
            totalReward
        );
        vm.warp(block.timestamp + 12);
        mL1.stakingDepositReward();
        (totalBalance, totalReward,,,,) = mL1.stakingState();

        console2.log(
            "rewardDebt",
            mL1.stakingCalculateRewardDebt(Alice),
            mL1.stakingCalculateRewardDebt(Bob),
            totalReward
        );
        vm.warp(block.timestamp + 24);
        mL1.stakingDepositReward();
        (totalBalance, totalReward,,,,) = mL1.stakingState();
        console2.log(
            "rewardDebt",
            mL1.stakingCalculateRewardDebt(Alice),
            mL1.stakingCalculateRewardDebt(Bob),
            totalReward
        );
    }

    function test_L1_StakingShouldRevert() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(mL1), type(uint256).max);
        vm.expectRevert(LibStaking.INSUFFICIENT_DEPOSIT.selector);
        mL1.stake(Alice,1_000_000 * 1 ether - 1);
    }

    function test_L1_Withdraw() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(mL1), type(uint256).max);
        mL1.stake(Alice,1_000_000 * 1 ether);

        vm.expectRevert(LibStaking.WITHDRAWAL_LOCKED.selector);
        mL1.stakingWithdrawal();

        mL1.stakingRequestWithdrawal(false);
        vm.warp(block.timestamp + LibStaking.LOCK_PERIOD);
        uint256 beforeBalance = mxcToken.balanceOf(Alice);
        mL1.stakingWithdrawal();
        assertEq(mxcToken.balanceOf(Alice), beforeBalance + 1_000_000 * 1 ether);

        vm.expectRevert(LibStaking.INSUFFICIENT_BALANCE.selector);
        mL1.stakingWithdrawal();
    }

    function test_L1_Slashing() external {
        vm.startPrank(Alice);
        mxcToken.approve(address(mL1), type(uint256).max);
        mL1.stake(Alice,1_000_000 * 1 ether);

        vm.stopPrank();
        (uint256 totalBalanceBefore,,,,,) = mL1.stakingState();
        mL1.stakingSlashing(Alice);

        (uint256 balance,,) = mL1.stakingUserState(Alice);
        assertEq(balance, 1_000_000 * 1 ether - (1_000_000 * 1 ether / 32));
        (uint256 totalBalanceAfter,,,,,) = mL1.stakingState();

        assertEq(totalBalanceBefore, totalBalanceAfter + (1_000_000 * 1 ether / 32));
    }
}
