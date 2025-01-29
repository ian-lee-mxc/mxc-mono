// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../tko/IMxcToken.sol";
import "../../common/IAddressResolver.sol";
import "../../common/LibStrings.sol";
import {EssentialContract} from "../../common/EssentialContract.sol";
import {IL1Staking} from "./IL1Staking.sol";

/// @title L1Staking
/// @notice A contract that offers helper functions to handle staking.
/// @custom:security-contact luanxu@mxc.org
contract L1Staking is EssentialContract, IL1Staking {

    modifier whenStakingBalancesAbove() {
        if (stakingState.stakingBalances[msg.sender] < MIN_DEPOSIT) {
            revert INSUFFICIENT_BALANCE();
        }
        _;
    }

    struct StakingState {
        mapping(address => uint256) stakingBalances;
        mapping(address => uint256) lastClaimedEpoch; // Track the last epoch when the user claimed rewards
        mapping(address => uint256) withdrawalRequestEpoch;
        uint256 totalBalance;
        uint256 totalReward;
        uint64 lastDepositRewardTime; // last deposit reward time
        uint64 rewardBeginEpoch;
        uint64 __reserved2;
        uint64 __reserved3;
        uint256[40] __gap;
    }

    /// @dev Emitted when user staking mxc token.
    event Staking(address indexed user, uint256 amount);

    /// @dev Emitted when deposit reward.
    event DepositReward(address indexed user, uint256 amount);

    /// @dev Emitted when user withdraw.
    event Withdrawal(address indexed user, uint256 amount);

    /// @dev Emitted when user claim reward.
    event ClaimReward(address indexed user, uint256 amount);

    /// @dev Emitted when user slash.
    event Slash(address indexed user, uint256 amount);

    error INSUFFICIENT_DEPOSIT();
    error INSUFFICIENT_BALANCE();
    error WITHDRAWAL_LOCKED();
    error REWARD_ALREADY_CLAIMED();

    uint256 public constant MIN_DEPOSIT = 1_000_000 ether;
    uint256 public constant WITHDRAWAL_LOCK_EPOCH = 2;

    StakingState public stakingState;
    uint256[50] private __gap;

    uint256 public constant EPOCH_DURATION = 7 days; // 1 week in seconds

    function init(
        address _owner,
        address _rollupAddressManager
    ) external initializer {
        __Essential_init(_owner, _rollupAddressManager);
        stakingState.rewardBeginEpoch = uint64(getCurrentEpoch());
    }

    /// @dev Deposits MXC token to be used as bonds.
    /// @param _user The user address to credit.
    /// @param _amount The amount of token to deposit.
    function stake(
        address _user,
        uint256 _amount
    ) whenNotPaused nonReentrant
    external
    {
        uint256 newBalance = stakingState.stakingBalances[_user] + _amount;
        if (newBalance < MIN_DEPOSIT) revert INSUFFICIENT_DEPOSIT();
        _mxc().transferFrom(msg.sender, address(this), _amount);
        stakingState.stakingBalances[_user] += _amount;
        stakingState.totalBalance += _amount;

        emit Staking(_user, _amount);
    }

    /// @dev Withdrawal request
    function stakingRequestWithdrawal(
        bool cancel
    )
    external
    {
        if (stakingState.stakingBalances[msg.sender] == 0) revert INSUFFICIENT_BALANCE();
        if (cancel) {
            stakingState.withdrawalRequestEpoch[msg.sender] = 0; // Reset the time of the withdrawal
        } else {
            stakingState.withdrawalRequestEpoch[msg.sender] = getCurrentEpoch();
        }
    }

    /// @dev User completes the withdrawal after the lock period
    function stakingWithdrawal()
    external whenNotPaused nonReentrant
    {
        uint256 amount = stakingState.stakingBalances[msg.sender]; // Get the user's staked balance

        if (amount == 0) revert INSUFFICIENT_BALANCE();

        if (
            stakingState.withdrawalRequestEpoch[msg.sender] == 0
            || getCurrentEpoch() < stakingState.withdrawalRequestEpoch[msg.sender] + WITHDRAWAL_LOCK_EPOCH
        ) {
            revert WITHDRAWAL_LOCKED();
        }

        // reset state
        stakingState.stakingBalances[msg.sender] = 0;
        stakingState.totalBalance -= amount;
        stakingState.lastClaimedEpoch[msg.sender] = 0;
        stakingState.withdrawalRequestEpoch[msg.sender] = 0;
        // Transfer the staked tokens to the user
        _mxc().transfer(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    /// @dev System deposits reward to all users based on their stake.
    function stakingDepositReward()
    external
    whenNotPaused nonReentrant
    {
        // Update last reward timestamp
        if (stakingState.lastDepositRewardTime == 0) {
            stakingState.lastDepositRewardTime = uint64(block.timestamp);
        }

        // Calculate time elapsed since last reward distribution
        uint256 timeElapsed = block.timestamp - uint256(stakingState.lastDepositRewardTime);
        if (timeElapsed == 0) return;
        // Update last reward timestamp
        uint256 _rewardAmount = calcReward();
        if (_rewardAmount == 0) return;
        _mxc().mint(address(this), _rewardAmount);
        stakingState.totalReward += _rewardAmount;
        stakingState.lastDepositRewardTime = uint64(block.timestamp);
        emit DepositReward(address(this), _rewardAmount);
    }

    /// @dev Calculate the debt reward owed to a user
    /// @param user The user address to credit.
    /// @return The debt reward owed to the user
    function stakingCalculateRewardDebt(
        address user
    )
    public
    view
    returns (uint256)
    {
        uint256 lastClaimedEpoch = stakingState.lastClaimedEpoch[user];
        if(lastClaimedEpoch == 0) {
            lastClaimedEpoch = stakingState.rewardBeginEpoch;
        }
        uint256 currentEpoch = getCurrentEpoch();

        if (lastClaimedEpoch >= currentEpoch) return 0; // Reward already claimed for this epoch

        uint256 timeElapsed = (currentEpoch - lastClaimedEpoch) * EPOCH_DURATION;
        // Calculate the time elapsed since the last claim
        if (timeElapsed == 0 || stakingState.stakingBalances[user] == 0) return 0;

        // Calculate the reward based on the user's staked amount, total supply, and elapsed time
        uint256 share = stakingState.stakingBalances[user] * 1e5 / stakingState.totalBalance;
        return (
            (stakingState.totalReward * share) * timeElapsed
            / ((currentEpoch - stakingState.rewardBeginEpoch) * EPOCH_DURATION) / 1e5
        );
    }

    /// @dev User claims their accumulated interest and transfers it to their wallet.
    function stakingClaimReward()
    external
    {
        _stakingClaimReward(msg.sender);
    }

    function _stakingClaimReward(address _user) internal
    whenNotPaused nonReentrant
    {
        uint256 currentEpoch = getCurrentEpoch();
        if (stakingState.lastClaimedEpoch[_user] >= currentEpoch) revert REWARD_ALREADY_CLAIMED();

        uint256 reward = stakingCalculateRewardDebt(_user); // Calculate the interest owed to the user
        if (reward == 0) revert ZERO_VALUE();

        stakingState.lastClaimedEpoch[_user] = currentEpoch;
        _mxc().transfer(_user, reward);
        emit ClaimReward(_user, reward);

    }

    /// @dev Slash a user's bond balance. Dishonest behavior and failure to meet online rate targets
    /// during the period
    /// @param _user The user address to credit.
    /// @param _rate The rate to slash, 10 is 10%
    function stakingSlashing(
        address _user,
        uint256 _rate
    ) external onlyFromOptionalNamed(LibStrings.B_STAKING_SLASHER)
    {
        uint256 amount = stakingState.stakingBalances[_user];
        if (amount == 0) return;
        uint256 punishAmount = amount * _rate / 100;
        stakingState.stakingBalances[_user] -= punishAmount;
        stakingState.totalBalance -= punishAmount;
        emit Slash(_user, punishAmount);
    }

    /// @dev punish user epoch reward
    /// @param _user The user address to credit.
    /// @param _epochAmount The epoch amount to punish
    function pauseUserReward(
        address _user,
        uint256 _epochAmount
    ) external onlyFromOptionalNamed(LibStrings.B_STAKING_SLASHER)
    {
        uint256 currentEpoch = getCurrentEpoch();
        _stakingClaimReward(_user);
        stakingState.lastClaimedEpoch[_user] = currentEpoch + _epochAmount;
    }

    function stakingUserState(address _user) external view returns (uint256, uint256, uint256) {
        return (
            stakingState.stakingBalances[_user],
            stakingState.lastClaimedEpoch[_user],
            stakingState.withdrawalRequestEpoch[_user]
        );
    }

    /// @dev Get the current epoch based on the current block timestamp
    /// @return The current epoch ID
    function getCurrentEpoch() public view returns (uint256) {
        return block.timestamp / EPOCH_DURATION;
    }

    /// @dev Calculate the reward for the current epoch
    /// @return The reward for the current epoch
    function calcReward()
    internal
    view
    returns (uint256)
    {
        uint256 elapsedSeconds = block.timestamp - stakingState.lastDepositRewardTime;
        uint256 reward = (_mxc().totalSupply() * 950 / 100 / 365 days) * elapsedSeconds; // max
        // apr ~= 9.99%

        // Limit max reward to 1e5
        if (reward > 1e5 * 1 ether) {
            reward = 1e5 * 1 ether;
        }
        // Round down to the nearest 1e16
        return (reward / 1e16) * 1e16;
    }


    function _mxc() private view returns (IMxcToken) {
        return IMxcToken(IAddressResolver(this).resolve(LibStrings.B_TAIKO_TOKEN, false));
    }
}
