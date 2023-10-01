// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

struct MetaTxContextStorage {
  address trustedForwarder;
}

struct ERC721Checkpoint {
    uint256 timestamp;
    uint256 totalAmount;
    uint256 depositedAmount;
    uint256 rewardPerToken;
    uint256 totalSupplyAtTime;
}

struct ERC721Infos {
  string name;
  string symbol;
  string description;
  uint256 id;
  uint256 maxSupply;
  uint256 collectionRewardRate;
  uint256 individualShare;
  address rewardToken;
}

struct ERC721Token {
  string name;
  string symbol;
  string description;
  uint256 id;
  uint256 maxSupply;
  string baseUri;
  // Mapping token ID to URI
  mapping(uint256 => string) tokenURIs;
  // Mapping token ID to owner address
  mapping(uint256 => address) owners;
  // Mapping owner address to token count
  mapping(address => uint256) erc721Balances;
  // Mapping token ID to approved address
  mapping(uint256 => address) tokenApprovals;
  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) operatorApprovals;
  // Mapping from owner to operator erc20 balance
  mapping(address => mapping(address => uint256)) allowances;
  // Total shares of this collection
  uint256 collectionRewardRate;
  // collectionRewardRate / holders
  uint256 individualShare;
  // nft buy price in wei
  uint256 tokenPrice;
  // Reward token address
  address rewardToken;

  // All rewards deposited by project admin
  ERC721Checkpoint[] checkpoints;
  uint256 actualCheckpointsIndex;
  // User Claimed Bal
  // mapping(address => uint256) userLastRewardPerToken; // replace by last index ??
  mapping(address => uint256) lastClaimedCheckpointIndex;
  // User Temporary balance used to store previous rewards before new asset mint 
  mapping(address => uint256) dividendsTempBalance;
  // User available rewards balance
  mapping(address => uint256) dividends;
  // remainder of reward dispatch, stored when full supply reached for next drop
  uint256 leftoverReward;
}


struct ERC20Token {
  string name;
  string symbol;
  uint8 decimals;
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowances;
  uint256 totalSupply;
}

struct ERC20TokenConfig {
  string name;
  string symbol;
  uint8 decimals;
}
