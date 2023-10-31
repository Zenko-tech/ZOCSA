// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

struct MetaTxContextStorage {
  address trustedForwarder;
}

struct Whitelist {
    // name of this whitelist
    string name;
    // all whitelist admins
    address[] admins;
    // all users whitelisted
    address[] addresses;
    // Add Zenko KYC/Legal contracts signature for POCSA
    bool addZenkoWhiteList;
}

// OCSA Reward Checkpoint
struct ZOCSACheckpoint {
    uint256 timestamp;
    uint256 totalAmount;
    uint256 depositedAmount;
    uint256 rewardPerToken;
    uint256 totalSupplyAtTime;
    uint256 boundedSupplyAtTime;
    uint256 unboundedSupplyAtTime;
}

// OCSA Collection display info
struct ZOCSAInfos {
  address collectionAddress;
  string name;
  string symbol;
  string description;
  uint32 whitelistId;
  uint256 totalSupply;
  uint256 maxSupply;
  uint256 totalUnboundedOcsa;
  uint256 totalBoundedOcsa;
  uint256 collectionRewardRate;
  uint256 individualShare; // to divide by 1e18 to retrieve correct value
  uint256 tokenPrice;
  address rewardToken;
  address collectionTreasury;
  uint256 actualCheckpointsIndex;
  uint256 leftoverReward;
}

// OCSA Collection user display info
struct ZOCSAUserInfo {
  address collectionAddress;
  string name;
  string symbol;
  string description;
  uint256 whitelistStatus;
  uint256 totalSupply;
  uint256 maxSupply;
  uint256 totalUnboundedOcsa;
  uint256 totalBoundedOcsa;
  uint256 collectionRewardRate;
  uint256 individualShare; // to divide by 1e18 to retrieve correct value
  uint256 tokenPrice;
  address rewardToken;
  uint256 lastClaimedCheckpointIndex;
  uint256 balanceOfAvailableReward;
  uint256 balanceOfOCSA;
  uint256 balanceOfBoundedOCSA;
  uint256 balanceOfUnboundedOCSA;
  uint256 actualCheckpointsIndex;
}

// OCSA Token Collection Info
struct ZOCSAToken {
  string name;
  string symbol;
  string description;
  uint8 decimals;
  uint256 totalSupply;
  uint256 maxSupply;
  // all ocsas not linked to an income receiver
  uint256 totalUnboundedOcsa;
  // all ocsas claimed as income receiver by their actual owner
  uint256 totalBoundedOcsa;
  // user address => all bounded + unbounded user's ocsas
  mapping(address => uint256) balances; 
  // user address => unbounded Ocsa balance
  mapping(address => uint256) unboundedOcsas;
  // user address => bounded Ocsa balance
  mapping(address => uint256) boundedOcsas;
  mapping(address => mapping(address => uint256)) allowances;

  // Total shares of this collection
  uint256 collectionRewardRate;
  // collectionRewardRate / max supply 
  uint256 individualShare; // to divide by 1e18 to retrieve correct value
  // ocsa buy price in wei
  uint256 tokenPrice;
  // Reward token address
  address rewardToken;
  // Treasury Address of this collection
  address collectionTreasury;

  // All rewards deposited by project admin
  ZOCSACheckpoint[] checkpoints;
  
  // User last claimed checkpoint
  mapping(address => uint256) lastClaimedCheckpointIndex;
  // User Temporary balance used to store previous rewards before new asset mint 
  mapping(address => uint256) dividendsTempBalance;
  // User available rewards balance
  mapping(address => uint256) dividends;
  // remainder of reward dispatch, stored when full supply reached for next drop
  uint256 leftoverReward;
}

// OCSA Deployment Infos
struct ZOCSATokenConfig {
    string name;
    string symbol;
    string description;
    uint256 maxSupply;
    uint256 collectionRewardRate;
    uint256 tokenPrice;
    address rewardToken;
    address collectionTreasury;
    address[] adminAddresses;
    address[] whitelistAddresses;
}
