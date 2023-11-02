// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ZOCSA } from "../facades/ZOCSA.sol";
import { IZOCSAFacet } from "../interfaces/IZOCSAFacet.sol";
import { ZOCSAToken, ZOCSATokenConfig, ZOCSAInfos, ZOCSAUserInfo, ZOCSACheckpoint } from "../shared/Structs.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { ReentrancyGuard } from "../shared/ReentrancyGuard.sol";
import { LibZOCSA } from "../libs/LibZOCSA.sol";
import { LibWhitelist } from "../libs/LibWhitelist.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
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

  /**
   * @dev Mints new ZOCSA tokens.
   * @dev Only whitelisted user can receive Bounded OCSA after KYC / Legal Contract / Payment Received
   * @param token The token address for minting.
   * @param from The address to mint tokens from.
   * @param to The address to mint tokens to. (need to be whitelisted)
   * @param count The number of tokens to mint.
   */
  function ZOCSAMint(
    address token,
    address from,
    address to,
    uint256 count
  ) external onlyZOCSAFacades {
    LibZOCSA.mint(token, from, to, count);
  }

  /**
   * @dev Approve an allowance for the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   * @param amount The amount to approve.
   */
  function ZOCSAApprove(
    address token,
    address account,
    address spender,
    uint256 amount
  ) external onlyZOCSAFacades {
    LibZOCSA.approve(token, account, spender, amount);
  }

  /**
   * @dev Transfer a token.
   * @param caller The caller address.
   * @param from The from address.
   * @param to The to address.
   * @param amount The amount to transfer.
   */
  function ZOCSATransfer(
    address token,
    address caller,
    address from,
    address to,
    uint256 amount
  ) external onlyZOCSAFacades {
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
  function ZOCSAName(address token) external view returns (string memory) {
    return LibAppStorage.diamondStorage().zOcsas[token].name;
  }

  /**
   * @dev Returns the symbol of the token.
   */
  function ZOCSASymbol(address token) external view returns (string memory) {
    return LibAppStorage.diamondStorage().zOcsas[token].symbol;
  }

  /**
   * @dev Returns the decimals places of the token.
   */
  function ZOCSADecimals(address token) external view returns (uint8) {
    return LibAppStorage.diamondStorage().zOcsas[token].decimals;
  }

  /**
   * @dev Get the total supply.
   */
  function ZOCSATotalSupply(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].totalSupply;
  }

  /**
   * @dev Get the balance of the given wallet.
   * @param account The account address.
   */
  function ZOCSABalanceOf(address token, address account) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].balances[account];
  }

  /**
   * @dev Get the allowance of the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   */
  function ZOCSAAllowance(
    address token,
    address account,
    address spender
  ) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].allowances[account][spender];
  }

  /*
    IZOCSAFacet interface implementation
    WRITE FUNCTIONS
  */

  /**
   * @dev Deploy new token.
   * @param config Token config.
   */
  function ZOCSADeployToken(
    ZOCSATokenConfig memory config
  ) external isDiamondAdmin returns (address) {
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

    AppStorage storage s = LibAppStorage.diamondStorage();
    address token = address(new ZOCSA(this));
    s.zOcsaCollections.push(token);
    s.zOcsaApprovedFacades[token] = true;

    ZOCSAToken storage t = s.zOcsas[token];
    t.name = config.name;
    t.symbol = config.symbol;
    t.description = config.description;
    t.decimals = 0;
    t.maxSupply = config.maxSupply;
    t.collectionRewardRate = config.collectionRewardRate;
    t.tokenPrice = config.tokenPrice;
    t.rewardToken = config.rewardToken;
    uint256 _tokenIndividualShare = (t.collectionRewardRate * 1e18) / t.maxSupply;
    t.individualShare = _tokenIndividualShare;
    t.transferPaused = config.transferPaused;

    emit ZOCSANewToken(token);
    return token;
  }

  /**
   * @dev Allow user to withdraw their earning
   */
  function ZOCSAWithdrawUserEarnings(
    address token,
    address from,
    address to,
    uint256 amount
  ) external nonReentrant onlyZOCSAFacades {
    LibZOCSA.withdrawUserReward(token, from, to, amount);
  }

  /**
   * @notice Bound OCSA to actual owner, which activate the income generating property of OCSA
   * @param amount The amount of OCSA to bound to actual owner.
   */
  function ZOCSABoundOCSA(address token, address user, uint256 amount) external onlyZOCSAFacades {
    LibZOCSA.boundUserOCSA(token, user, amount);
  }

  /*
    IZOCSAFacet interface implementation
    VIEW FUNCTIONS
  */

  /**
   * @dev Returns all deployed nft contracts infos.
   */
  function ZOCSAGetAllCollectionsInfos() external view returns (ZOCSAInfos[] memory) {
    return LibZOCSA.getAllCollectionsInfos();
  }

  /**
   * @dev Returns specific nft contracts infos.
   */
  function ZOCSAGetCollectionInfos(address token) external view returns (ZOCSAInfos memory) {
    return LibZOCSA.getCollectionInfos(token);
  }

  /**
   * @dev Get information about a user's OCSA.
   * @param user The address of the user to return data from.
   * @return ZOCSAUserInfo Information about the specified ZOCSA collection user ocsa status.
   */
  function ZOCSAGetUserInfo(
    address token,
    address user
  ) external view returns (ZOCSAUserInfo memory) {
    return LibZOCSA.getUserInfo(token, user);
  }

  /**
   * @dev Returns all OCSAs collections deployed.
   */
  function ZOCSAGetAllCollections() external view returns (address[] memory) {
    return LibAppStorage.diamondStorage().zOcsaCollections;
  }

  /**
   * @dev Returns the project description of the token.
   */
  function ZOCSADescription(address token) external view returns (string memory) {
    return LibAppStorage.diamondStorage().zOcsas[token].description;
  }

  /**
   * @dev Get this collection project reward rate.
   */
  function ZOCSACollectionRewardRate(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].collectionRewardRate;
  }

  /**
   * @dev Get the max supply of this OCSA collection.
   */
  function ZOCSAMaxSupply(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].maxSupply;
  }

  /**
   * @dev Get the total Bounded OCSA Supply of this OCSA collection.
   */
  function ZOCSABoundedSupply(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].totalBoundedOcsa;
  }

  /**
   * @dev Get the total Unbounded OCSA Supply of this OCSA collection.
   */
  function ZOCSAUnboundedSupply(address token) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].totalUnboundedOcsa;
  }

  /**
   * @dev Returns the reward balance for this collection by this user (all ocsas earnings)
   * @param owner The owner address.
   */
  function ZOCSARewardBalanceOf(address token, address owner) external view returns (uint256) {
    return LibZOCSA.consultUserRewards(token, owner);
  }

  /**
   * @dev Returns the bounded ocsa balance of this user
   * @param owner The owner address.
   */
  function ZOCSABoundedBalanceOf(address token, address owner) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].boundedOcsas[owner];
  }

  /**
   * @dev Returns the unbounded ocsa balance of this user
   * @param owner The owner address.
   */
  function ZOCSAUnboundedBalanceOf(address token, address owner) external view returns (uint256) {
    return LibAppStorage.diamondStorage().zOcsas[token].unboundedOcsas[owner];
  }

  /**
   * @dev Returns the address of the reward token paid by the protocol
   */
  function ZOCSARewardToken(address token) external view returns (address) {
    return LibAppStorage.diamondStorage().zOcsas[token].rewardToken;
  }

  /**
   * @dev Returns the total dividend available to user in the collection
   */
  function ZOCSAGetAvailableDividends(address token) external view returns (uint256 amount) {
    return LibAppStorage.diamondStorage().zOcsas[token].dividends[token];
  }

  /**
   * @dev Returns the cost for one OCSA in this collection
   */
  function ZOCSAGetOCSAPrice(address token) external view returns (uint256 amount) {
    return LibAppStorage.diamondStorage().zOcsas[token].tokenPrice;
  }

  /**
   * @dev Returns all checkpoints for this collection
   */
  function ZOCSAGetCollectionCheckpoints(
    address token
  ) external view returns (ZOCSACheckpoint[] memory) {
    return LibAppStorage.diamondStorage().zOcsas[token].checkpoints;
  }
}
