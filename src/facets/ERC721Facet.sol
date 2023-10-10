// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ERC721 } from "../facades/ERC721.sol";
import { IERC721Facet } from "../interfaces/IERC721Facet.sol";
import { ERC721Token, ERC721Infos } from "../shared/Structs.sol";
import { LibERC721 } from "../libs/LibERC721.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { ReentrancyGuard } from "../shared/ReentrancyGuard.sol";
import { LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

error ERC721InvalidInput();
error ERC721InvalidReceiver(address receiver);
error ERC721NotEnoughAllowance(address owner, address spender);

contract ERC721Facet is IERC721Facet, AccessControl, ReentrancyGuard {

  /**
   * @dev Emitted when a token is approved for a spender.
   */
  event ERC721Approval(address token, address owner, address spender, uint256 value);
    /**
    * @dev Emitted when a new token is deployed.
    */
  event ERC721NewToken(address token);

  /*
    IERC721Facet interface implementation
  */

// #############################################################################################
// *		Write Functions
// #############################################################################################

  function erc721DeployToken(
    string memory name,
    string memory symbol,
    string memory description,
    string memory baseUri,
    uint256 maxSupply,
    uint256 collectionRewardRate,
    uint256 tokenPrice,
    address rewardToken
  ) isAdmin external returns(address) {
    if (
      LibString.len(name) == 0 || 
      LibString.len(symbol) == 0 || 
      LibString.len(description) == 0 || 
      LibString.len(baseUri) == 0 || 
      maxSupply == 0 ||
      collectionRewardRate == 0 ||
      tokenPrice == 0 || 
      rewardToken == address(0)
    ) {
      revert ERC721InvalidInput();
    }

    address token = address(new ERC721(this));
    LibAppStorage.diamondStorage().erc721Collections.push(token);
    LibAppStorage.diamondStorage().erc721ApprovedFacades[token] = true;

    ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
    t.name = name;
    t.symbol = symbol;
    t.description = description;
    t.baseUri = baseUri;
    t.maxSupply = maxSupply;
    t.collectionRewardRate = collectionRewardRate;
    t.tokenPrice = tokenPrice;
    t.rewardToken = rewardToken;

    LibERC721._setIndividualShare(token);
    emit ERC721NewToken(token);
    return token;
  }

  // TODO /!\ Only approved facades 
  function erc721WithdrawUserEarnings(
    address token,
    address from, 
    address to, 
    uint256 amount
  ) nonReentrant onlyERC721Facades external {
    LibERC721.withdrawUserReward(token, from, to, amount);
  }

  function erc721SafeTransferFromPayload(
		address token,
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external {revert("ERC721: Transfer Disabled");}

    function erc721SafeTransferFrom(
		address token,
        address from,
        address to,
        uint256 tokenId
    ) external {revert("ERC721: Transfer Disabled");}

    function erc721TransferFrom(
		address token,
        address from,
        address to,
        uint256 tokenId
    ) external {revert("ERC721: Transfer Disabled");}

    function erc721Approve(address token, address to, uint256 tokenId) external {revert("ERC721: Transfer Disabled");}

    function erc721SetApprovalForAll(address token, address operator, bool _approved) external {revert("ERC721: Transfer Disabled");}

  // #############################################################################################
// *		View Functions
// #############################################################################################

  function erc721GetAllCollectionsInfos() external view returns (ERC721Infos[] memory)
  {
    return LibERC721.getAllCollectionsInfos();
  }

  function erc721GetCollectionInfos(address token) external view returns (ERC721Infos memory)
  {
    return LibERC721.getCollectionInfos(token);

  }

  function erc721GetAllCollections() external view returns (address[] memory)
  {
    return LibAppStorage.diamondStorage().erc721Collections;
  }
  function erc721Name(address token) external view returns (string memory) {
    return LibAppStorage.diamondStorage().erc721s[token].name;
  }

  function erc721Symbol(address token) external view returns (string memory) {
    return LibAppStorage.diamondStorage().erc721s[token].symbol;
  }

  function erc721TokenURI(address token, uint256 tokenId) external view returns (string memory) {
    return LibERC721.tokenURI(token, tokenId);
  }

  function erc721Description(address token) external view returns (string memory) {
    return LibAppStorage.diamondStorage().erc721s[token].description;
  }

  function erc721CollectionRewardRate(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().erc721s[token].collectionRewardRate;
  }

  function erc721TotalSupply(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().erc721s[token].id;
  }

  function erc721MaxSupply(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().erc721s[token].maxSupply;
  }

  function erc721BalanceOf(address token, address account) external view returns (uint256) {
    return LibAppStorage.diamondStorage().erc721s[token].erc721Balances[account];
  }

  function erc721RewardBalanceOf(address token, address owner) external view returns (uint256) {
    return LibERC721.consultUserRewards(token, owner);
  }

  function erc721RewardToken(address token) external view returns (address) {
    return LibAppStorage.diamondStorage().erc721s[token].rewardToken;
  }

  function erc721OwnerOf(address token, uint256 tokenId) external view returns (address owner) {
    return LibAppStorage.diamondStorage().erc721s[token].owners[tokenId];
  }

  function erc721IsApprovedForAll(address token, address owner, address operator) external view returns (bool) {
    return LibAppStorage.diamondStorage().erc721s[token].operatorApprovals[owner][operator];
  }

  function erc721GetApproved(address token, uint256 tokenId) external view returns (address operator) {
    return LibAppStorage.diamondStorage().erc721s[token].tokenApprovals[tokenId];
  }

  function erc721GetAvailableDividends(address token) external view returns (uint256 amount) {
    return LibAppStorage.diamondStorage().erc721s[token].dividends[token];
  }

  function erc721GetOCSAPrice(address token) external view returns (uint256 amount) {
    return LibAppStorage.diamondStorage().erc721s[token].tokenPrice;
  }
  
}
