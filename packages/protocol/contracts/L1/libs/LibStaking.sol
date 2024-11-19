// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../../tko/IMxcToken.sol";
import "../../common/IAddressResolver.sol";
import "../../common/LibStrings.sol";
import "../TaikoData.sol";

/// @title LibStaking
/// @notice A library that offers helper functions to handle staking.
/// @custom:security-contact luanxu@mxc.org
library LibStaking {
    /// @dev Emitted when user staking mxc token.
    event Staking(address indexed user, uint256 amount);

    /// @dev Emitted when deposit reward.
    event DepositReward(address indexed user, uint256 amount);

    /// @dev Emitted when user withdraw.
    event Withdrawal(address indexed user, uint256 amount);

    /// @dev Emitted when user claim reward.
    event ClaimReward(address indexed user, uint256 amount);

    error INSUFFICIENT_DEPOSIT();
    error INSUFFICIENT_BALANCE();
    error WITHDRAWAL_LOCKED();
    error ZERO_VALUE();

    uint256 public constant REWARD_BEGIN_TIME = 1_729_689_600;
    uint256 public constant LOCK_PERIOD = 60 days;
    uint256 public constant MIN_DEPOSIT = 6_000_000;

    /// @dev Deposits MXC token to be used as bonds.
    /// @param _stakingState Current TaikoData.StakingState.
    /// @param _resolver Address resolver interface.
    /// @param _amount The amount of token to deposit.
    function stake(
        TaikoData.StakingState storage _stakingState,
        IAddressResolver _resolver,
        uint256 _amount
    )
        internal
    {
        uint256 newBalance = _stakingState.stakingBalances[msg.sender] + _amount;
        if (newBalance < MIN_DEPOSIT * 1 ether) revert INSUFFICIENT_DEPOSIT();
        _tko(_resolver).transferFrom(msg.sender, address(this), _amount);
        _stakingState.stakingBalances[msg.sender] += _amount;
        _stakingState.totalBalance += _amount;

        emit Staking(msg.sender, _amount);
    }

    /// @dev Withdrawal request
    /// @param _stakingState Current TaikoData.StakingState.
    function stakingRequestWithdrawal(TaikoData.StakingState storage _stakingState) internal {
        if (_stakingState.stakingBalances[msg.sender] == 0) revert INSUFFICIENT_BALANCE();
        _stakingState.withdrawalRequestTime[msg.sender] = uint64(block.timestamp);
    }

    /// @dev Cancel the withdrawal request
    /// @param _stakingState Current TaikoData.StakingState.
    function stakingCancelWithdrawal(TaikoData.StakingState storage _stakingState) internal {
        if (_stakingState.withdrawalRequestTime[msg.sender] == 0) revert INSUFFICIENT_BALANCE();
        _stakingState.withdrawalRequestTime[msg.sender] = 0; // Reset the time of the withdrawal
            // request
    }

    /// @dev User completes the withdrawal after the lock period
    /// @param _stakingState Current TaikoData.StakingState.
    function stakingWithdrawal(
        TaikoData.StakingState storage _stakingState,
        IAddressResolver _resolver
    )
        internal
    {
        uint256 amount = _stakingState.stakingBalances[msg.sender]; // Get the user's staked balance

        if (amount == 0) revert INSUFFICIENT_BALANCE();

        if (
            _stakingState.withdrawalRequestTime[msg.sender] == 0
                || block.timestamp < _stakingState.withdrawalRequestTime[msg.sender] + LOCK_PERIOD
        ) {
            revert WITHDRAWAL_LOCKED();
        }

        // reset state
        _stakingState.stakingBalances[msg.sender] = 0;
        _stakingState.totalBalance -= amount;
        _stakingState.lastClaimedTime[msg.sender] = 0;
        _stakingState.withdrawalRequestTime[msg.sender] = 0;
        // Transfer the staked tokens to the user
        _tko(_resolver).transfer(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    /// @dev System deposits reward to all users based on their stake.
    /// @param _stakingState Current TaikoData.StakingState.
    /// @param _resolver Address resolver interface.
    function stakingDepositReward(
        TaikoData.StakingState storage _stakingState,
        IAddressResolver _resolver
    )
        internal
    {
        // Update last reward timestamp
        if (_stakingState.lastDepositRewardTime == 0) {
            _stakingState.lastDepositRewardTime = uint64(block.timestamp);
        }

        // Calculate time elapsed since last reward distribution
        uint256 timeElapsed = block.timestamp - uint256(_stakingState.lastDepositRewardTime);
        if (timeElapsed == 0) return;
        // Update last reward timestamp
        uint256 _rewardAmount = calcReward(_stakingState, _resolver);
        if (_rewardAmount == 0) return;
        _mxc(_resolver).mint(address(this), _rewardAmount);
        _stakingState.totalReward += _rewardAmount;
        _stakingState.lastDepositRewardTime = uint64(block.timestamp);
        emit DepositReward(address(this), _rewardAmount);
    }

    function calcReward(
        TaikoData.StakingState storage _stakingState,
        IAddressResolver _resolver
    )
        internal
        view
        returns (uint256)
    {
        uint256 elapsedSeconds = block.timestamp - _stakingState.lastDepositRewardTime;
        uint256 reward = (_mxc(_resolver).totalSupply() / 16 / 365 days) * elapsedSeconds; // max
            // apr is 6.06%

        // Limit max reward to 1e5
        if (reward > 1e5 * 1 ether) {
            reward = 1e5 * 1 ether;
        }
        // Round down to the nearest 1e16
        return (reward / 1e16) * 1e16;
    }

    /// @dev Calculate the debt reward owed to a user
    /// @param _stakingState Current TaikoData.StakingState.
    /// @param user The user address to credit.
    /// @return The debt reward owed to the user
    function stakingCalculateRewardDebt(
        TaikoData.StakingState storage _stakingState,
        address user
    )
        internal
        view
        returns (uint256)
    {
        uint256 lastClaimedTime = _stakingState.lastClaimedTime[user];
        if (lastClaimedTime == 0) lastClaimedTime = REWARD_BEGIN_TIME;

        uint256 timeElapsed = uint256(_stakingState.lastDepositRewardTime) - lastClaimedTime;
        // Calculate the time elapsed since the last claim
        if (timeElapsed == 0 || _stakingState.stakingBalances[user] == 0) return 0;

        // Calculate the reward based on the user's staked amount, total supply, and elapsed time
        uint256 share = _stakingState.stakingBalances[user] * 1e5 / _stakingState.totalBalance;
        return (
            (_stakingState.totalReward * share) * timeElapsed
                / (_stakingState.lastDepositRewardTime - REWARD_BEGIN_TIME) / 1e5
        );
    }

    /// @dev User claims their accumulated interest and transfers it to their wallet.
    /// @param _stakingState Current TaikoData.StakingState.
    /// @param _resolver Address resolver interface.
    function stakingClaimReward(
        TaikoData.StakingState storage _stakingState,
        IAddressResolver _resolver
    )
        internal
    {
        uint256 reward = stakingCalculateRewardDebt(_stakingState, msg.sender); // Calculate the
            // interest owed to the user
        if (reward == 0) revert ZERO_VALUE();
        _stakingState.lastClaimedTime[msg.sender] = uint64(block.timestamp);
        _tko(_resolver).transfer(msg.sender, reward);
        emit ClaimReward(msg.sender, reward);
    }

    /// @dev Gets a user's current MXC token bond balance.
    /// @param _stakingState Current TaikoData.StakingState.
    /// @param _user The user address to credit.
    /// @return  The current token balance
    function stakingBalanceOf(
        TaikoData.StakingState storage _stakingState,
        address _user
    )
        internal
        view
        returns (uint256)
    {
        return (_stakingState.stakingBalances[_user]);
    }

    function _tko(IAddressResolver _resolver) private view returns (IERC20) {
        return IERC20(_resolver.resolve(LibStrings.B_TAIKO_TOKEN, false));
    }

    function _mxc(IAddressResolver _resolver) private view returns (IMxcToken) {
        return IMxcToken(_resolver.resolve(LibStrings.B_TAIKO_TOKEN, false));
    }
}
