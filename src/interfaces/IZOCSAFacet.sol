// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "../shared/Structs.sol";

/**
 * @dev ZOCSA diamond facet interface.
 */
interface IZOCSAFacet {

  /**
   * @dev Returns the name of the token.
   */
  function ZOCSAName(address token) external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
   */
  function ZOCSASymbol(address token) external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
   */
  function ZOCSADecimals(address token) external view returns (uint8);

  /**
   * @dev Get the total supply.
   */
  function ZOCSATotalSupply(address token) external view returns (uint256);

  /**
   * @dev Get the balance of the given wallet.
   * @param account The account address.
   */
  function ZOCSABalanceOf(address token, address account) external view returns (uint256);

  /**
   * @dev Get the allowance of the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   */
  function ZOCSAAllowance(address token, address account, address spender) external view returns (uint256);

  /**
   * @dev Mints new ZOCSA tokens.
   * @dev Only whitelisted user can receive Bounded OCSA after KYC / Legal Contract / Payment Received
   * @param token The token address for minting.
   * @param from The address to mint tokens from.
   * @param to The address to mint tokens to. (need to be whitelisted)
   * @param count The number of tokens to mint.
   */
  function ZOCSAMint(address token, address from, address to, uint256 count) external;

  /**
   * @dev Approve an allowance for the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   * @param amount The amount to approve.
   */
  function ZOCSAApprove(address token, address account, address spender, uint256 amount) external;

  /**
   * @dev Transfer a token.
   * @param caller The caller address.
   * @param from The from address.
   * @param to The to address.
   * @param amount The amount to transfer.
   */
  function ZOCSATransfer(address token, address caller, address from, address to, uint256 amount) external;

  /*
    OCSA implementation
  */

  /**
   * @dev Deploy new token.
   * @param config Token config.
   */
  function ZOCSADeployToken(ZOCSATokenConfig memory config) external returns (address);
  
  /**
    * @dev Returns all deployed ocsa contracts infos.
    */
  function ZOCSAGetAllCollectionsInfos() external view returns (ZOCSAInfos[] memory);

  /**
    * @dev Returns specific ocsa contracts infos.
    */
  function ZOCSAGetCollectionInfos(address token) external view returns (ZOCSAInfos memory);

  // /**
  //   * @dev Returns all OCSAs collections deployed.
  //   */
  // function ZOCSAGetAllCollections() external view returns (address[] memory);

  /**
    * @dev Get information about a user's OCSA.
    * @param user The address of the user to return data from.
    * @return ZOCSAUserInfo Information about the specified ZOCSA collection user ocsa status.
    */
  function ZOCSAGetUserInfo(address token, address user) external view returns (ZOCSAUserInfo memory);

  /**
   * @dev Returns the project description of the token.
   */
  function ZOCSADescription(address token) external view returns (string memory);

  // /**
  //  * @dev Get this collection project reward rate.
  //  */
  // function ZOCSACollectionRewardRate(address token) external view returns (uint256);

  /**
   * @dev Get the max supply of this OCSA collection.
   */
  function ZOCSAMaxSupply(address token) external view returns (uint256);

  /**
   * @dev Get the total Bounded OCSA Supply of this OCSA collection.
   */
  function ZOCSABoundedSupply(address token) external view returns (uint256);

  /**
   * @dev Get the total Unbounded OCSA Supply of this OCSA collection.
   */
  function ZOCSAUnboundedSupply(address token) external view returns (uint256);

  /**
   * @dev Returns the reward balance for this collection by this user (all ocsas earnings) 
   * @param owner The owner address.
   */
  function ZOCSARewardBalanceOf(address token, address owner) external view returns (uint256);

  /**
   * @dev Returns the address of the reward token paid by the protocol
   */
  function ZOCSARewardToken(address token) external view returns (address);

  /**
   * @dev Returns the bounded ocsa balance of this user 
   * @param owner The owner address.
   */
  function ZOCSABoundedBalanceOf(address token, address owner) external view returns (uint256);

  /**
   * @dev Returns the unbounded ocsa balance of this user 
   * @param owner The owner address.
   */
  function ZOCSAUnboundedBalanceOf(address token, address owner) external view returns (uint256);
  /**
   * @dev Returns the total dividend available to user in the collection
   */
  function ZOCSAGetAvailableDividends(address token) external view returns (uint256 amount);

  /**
   * @dev Returns the cost for one OCSA in this collection
   */
  function ZOCSAGetOCSAPrice(address token) external view returns (uint256 amount);

  /**
   * @dev Allow user to withdraw their earning 
   */
	function ZOCSAWithdrawUserEarnings(address token, address from, address to, uint256 amount) external;
  
  /**
   * @notice Bound OCSA to actual owner, which activate the income generating property of OCSA
   * @param amount The amount of OCSA to bound to actual owner.
  */
  function ZOCSABoundOCSA(address token, address user, uint256 amount) external;

  /**
   * @dev Updates the project description for a ZOCSA token.
   * @param from admin address.
   * @param token The token address to update.
   * @param newDescription The new description string.
   */
  function ZOCSAUpdateProjectDescription(address token, address from,  string memory newDescription) external;

  /**
   * @dev Dispatches user rewards for a ZOCSA token.
   * @param token The token address for which to dispatch rewards.
   * @param from admin address who pay the dispatch.
   * @param amount The amount of rewards to dispatch.
   */
  function ZOCSADispatchUserReward(address token, address from, uint256 amount) external;

  /**
   * @dev Returns all checkpoints for this collection
   */
  function ZOCSAGetCollectionCheckpoints(address token) external view returns (ZOCSACheckpoint[] memory);
}
