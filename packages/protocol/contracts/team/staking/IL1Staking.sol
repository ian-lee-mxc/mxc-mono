
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IL1Staking {
    function stake(address user, uint256 amount) external;
    function stakingRequestWithdrawal(bool cancel) external;
    function stakingWithdrawal() external;
    function stakingCalculateRewardDebt(address user) external view returns (uint256);
    function stakingClaimReward() external;
    function stakingClaimReward(address user) external;
    function stakingDepositReward() external;
    function stakingDepositReward(uint256 amount) external;
    function pauseUserReward(address user,uint256 epochAmount) external;
    function stakingSlashing(address user,uint256 rate) external;
    function getEpochReward() external view returns (uint256);
    function getCurrentEpoch() external view returns (uint256);
    function stakingUserState(address user) external view returns (uint256 balance,uint256 lastClaimedEpoch,uint256 withdrawalRequestEpoch);
}
