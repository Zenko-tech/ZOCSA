// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// pOCSA Reward Checkpoint
struct POCSACheckpoint {
    uint256 timestamp;
    uint256 totalAmount;
    uint256 depositedAmount;
    uint256 rewardPerToken;
    uint256 totalSupplyAtTime;
}
// pOCSA Collection display info
struct POCSAInfos {
  address collectionAddress;
  string name;
  string symbol;
  string description;
  uint256 totalSupply;
  uint256 maxSupply;
  uint256 collectionRewardRate;
  uint256 individualShare;
  uint256 tokenPrice;
  address rewardToken;
  uint256 actualCheckpointsIndex;
  uint256 leftoverReward;
}
// pOCSA Token Collection Info
struct POCSAToken {
  string name;
  string symbol;
  string description;
  uint8 decimals;
  uint256 totalSupply;
  uint256 maxSupply;
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowances;

  // Total shares of this collection
  uint256 collectionRewardRate;
  // collectionRewardRate / holders
  uint256 individualShare;
  // pocsa buy price in wei
  uint256 tokenPrice;
  // Reward token address
  address rewardToken;

  // All rewards deposited by project admin
  POCSACheckpoint[] checkpoints;
  
  uint256 actualCheckpointsIndex;
  // User last claimed checkpoint
  mapping(address => uint256) lastClaimedCheckpointIndex;
  // User Temporary balance used to store previous rewards before new asset mint 
  mapping(address => uint256) dividendsTempBalance;
  // User available rewards balance
  mapping(address => uint256) dividends;
  // remainder of reward dispatch, stored when full supply reached for next drop
  uint256 leftoverReward;
}

// pOCSA Deployment Infos
struct POCSATokenConfig {
    string name;
    string symbol;
    string description;
    uint256 maxSupply;
    uint256 collectionRewardRate;
    uint256 tokenPrice;
    address rewardToken;
}
