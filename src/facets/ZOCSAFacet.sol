// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ZOCSA } from "../facades/ZOCSA.sol";
import { IZOCSAFacet } from "../interfaces/IZOCSAFacet.sol";
import { ZOCSAToken, ZOCSATokenConfig, ZOCSAInfos } from "../shared/Structs.sol";
import { LibZOCSA } from "../libs/LibZOCSA.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { ReentrancyGuard } from "../shared/ReentrancyGuard.sol";
import { LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

error ZOCSAInvalidInput();
error ZOCSAInvalidReceiver(address receiver);
error ZOCSANotEnoughAllowance(address owner, address spender);

/**
 * This is a complex facet that use the ZOCSA facade to launch multiple ZOCSA tokens backed by a single diamond proxy.
 */
contract ZOCSAFacet is IZOCSAFacet, AccessControl, ReentrancyGuard {  

  /**
   * @dev Emitted when a new token is deployed.
   */
  event ZOCSANewToken(address token);

  /*
    IERC20Facet interface implementation
    WRITE FUNCTIONS
  */
  
  // TODO : WIP MARKET PLACE
    /**
   * @dev Approve an allowance for the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   * @param amount The amount to approve.
   */
  function ZOCSAApprove(address account, address spender, uint256 amount) external {
    LibZOCSA.approve(msg.sender, account, spender, amount);
  }

  // TODO : WIP MARKET PLACE
    /**
   * @dev Transfer a token.
   * @param caller The caller address.
   * @param from The from address.
   * @param to The to address.
   * @param amount The amount to transfer.
   */
  function ZOCSATransfer(address caller, address from, address to, uint256 amount) external {
    address token = msg.sender;

    if (to == address(0)) {
      revert ZOCSAInvalidReceiver(to);
    }

    ZOCSAToken storage t = LibAppStorage.diamondStorage().zOcsas[token];

    if (caller != from) {
      if (t.allowances[from][caller] < amount) {
        revert ZOCSANotEnoughAllowance(from, caller);
      }

      t.allowances[from][caller] -= amount;
    }

    LibZOCSA.transfer(token, from, to, amount);
  }

  /*
    IERC20Facet interface implementation
    VIEW FUNCTIONS
  */

  /**
   * @dev Returns the name of the token.
   */
  function ZOCSAName() external view returns (string memory) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].name;
  }

  /**
   * @dev Returns the symbol of the token.
   */
  function ZOCSASymbol() external view returns (string memory) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].symbol;    
  }

  /**
   * @dev Returns the decimals places of the token.
   */
  function ZOCSADecimals() external view returns (uint8) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].decimals;
  }

  /**
   * @dev Get the total supply.
   */
  function ZOCSATotalSupply() external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].totalSupply;
  }

  /**
   * @dev Get the balance of the given wallet.
   * @param account The account address.
   */
  function ZOCSABalanceOf(address account) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].balances[account];
  }

  /**
   * @dev Get the allowance of the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   */
  function ZOCSAAllowance(address account, address spender) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].allowances[account][spender];
  }



  /*
    IZOCSAFacet interface implementation
    WRITE FUNCTIONS
  */

  /**
   * @dev Deploy new token.
   * @param config Token config.
   */
  function ZOCSADeployToken(ZOCSATokenConfig memory config) external isAdmin() returns (address) {
    if (
      LibString.len(config.name) == 0 || 
      LibString.len(config.symbol) == 0 || 
      LibString.len(config.description) == 0 || 
      config.maxSupply == 0 ||
      config.collectionRewardRate == 0 ||
      config.tokenPrice == 0 || 
      config.rewardToken == address(0)
    ) {
      revert ZOCSAInvalidInput();
    }

    address token = address(new ZOCSA(this));
    LibAppStorage.diamondStorage().zOcsaCollections.push(token);
    LibAppStorage.diamondStorage().zOcsaApprovedFacades[token] = true;

    ZOCSAToken storage t = LibAppStorage.diamondStorage().zOcsas[token];
    t.name = config.name;
    t.symbol = config.symbol;
    t.description = config.description;
    t.decimals = 0;
    t.maxSupply = config.maxSupply;
    t.collectionRewardRate = config.collectionRewardRate;
    t.tokenPrice = config.tokenPrice;
    t.rewardToken = config.rewardToken;
    uint256 _tokenIndividualShare = t.collectionRewardRate / t.maxSupply;
    t.individualShare = _tokenIndividualShare;
    // TODO : For POCSA ?
    // LibZOCSA.mint(token, msg.sender, 100);
    emit ZOCSANewToken(token);
    return token;
  }

  /**
   * @dev Allow user to withdraw their earning 
   */
  function ZOCSAWithdrawUserEarnings(
    address from, 
    address to, 
    uint256 amount
  ) external nonReentrant() onlyZOCSAFacades() {
    LibZOCSA.withdrawUserReward(msg.sender, from, to, amount);
  }

  /**
   * @notice Bound OCSA to actual owner, which activate the income generating property of OCSA
   * @param amount The amount of OCSA to bound to actual owner.
  */
  function ZOCSABoundOCSA(address user, uint256 amount) external {
    LibZOCSA.boundUserOCSA(msg.sender, user, amount);
  }

  /*
    IZOCSAFacet interface implementation
    VIEW FUNCTIONS
  */

  /**
    * @dev Returns all deployed nft contracts infos.
    */
  function ZOCSAGetAllCollectionsInfos() external view returns (ZOCSAInfos[] memory)
  {
    return LibZOCSA.getAllCollectionsInfos();
  }

  /**
    * @dev Returns specific nft contracts infos.
    */
  function ZOCSAGetCollectionInfos() external view returns (ZOCSAInfos memory)
  {
    return LibZOCSA.getCollectionInfos(msg.sender);

  }

  /**
    * @dev Returns all OCSAs collections deployed.
    */
  function ZOCSAGetAllCollections() external view returns (address[] memory)
  {
    return LibAppStorage.diamondStorage().zOcsaCollections;
  }

  /**
   * @dev Returns the project description of the token.
   */
  function ZOCSADescription() external view returns (string memory) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].description;
  }

  /**
   * @dev Get this collection project reward rate.
   */
  function ZOCSACollectionRewardRate() external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].collectionRewardRate;
  }

  /**
   * @dev Get the max supply of this OCSA collection.
   */
  function ZOCSAMaxSupply() external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].maxSupply;
  }

  /**
   * @dev Get the total Bounded OCSA Supply of this OCSA collection.
   */
  function ZOCSABoundedSupply() external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].totalBoundedOcsa;
  }

  /**
   * @dev Get the total Unbounded OCSA Supply of this OCSA collection.
   */
  function ZOCSAUnboundedSupply() external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].totalUnboundedOcsa;
  }

  /**
   * @dev Returns the reward balance for this collection by this user (all ocsas earnings) 
   * @param owner The owner address.
   */
  function ZOCSARewardBalanceOf(address owner) external view returns (uint256) {
    return LibZOCSA.consultUserRewards(msg.sender, owner);
  }

  /**
   * @dev Returns the bounded ocsa balance of this user 
   * @param owner The owner address.
   */
  function ZOCSABoundedBalanceOf(address owner) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].boundedOcsas[owner];
  }

  /**
   * @dev Returns the unbounded ocsa balance of this user 
   * @param owner The owner address.
   */
  function ZOCSAUnboundedBalanceOf(address owner) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].unboundedOcsas[owner];
  }

  /**
   * @dev Returns the address of the reward token paid by the protocol
   */
  function ZOCSARewardToken() external view returns (address) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].rewardToken;
  }

  /**
   * @dev Returns the total dividend available to user in the collection
   */
  function ZOCSAGetAvailableDividends() external view returns (uint256 amount) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].dividends[msg.sender];
  }

  /**
   * @dev Returns the cost for one OCSA in this collection
   */
  function ZOCSAGetOCSAPrice() external view returns (uint256 amount) {
    return LibAppStorage.diamondStorage().zOcsas[msg.sender].tokenPrice;
  }
}
