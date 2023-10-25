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
  function ZOCSAName() external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
   */
  function ZOCSASymbol() external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
   */
  function ZOCSADecimals() external view returns (uint8);

  /**
   * @dev Get the total supply.
   */
  function ZOCSATotalSupply() external view returns (uint256);

  /**
   * @dev Get the balance of the given wallet.
   * @param account The account address.
   */
  function ZOCSABalanceOf(address account) external view returns (uint256);

  /**
   * @dev Get the allowance of the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   */
  function ZOCSAAllowance(address account, address spender) external view returns (uint256);

  /**
   * @dev Approve an allowance for the given spender for the given owner wallet.
   * @param account The account address.
   * @param spender The spender address.
   * @param amount The amount to approve.
   */
  function ZOCSAApprove(address account, address spender, uint256 amount) external;

  /**
   * @dev Transfer a token.
   * @param caller The caller address.
   * @param from The from address.
   * @param to The to address.
   * @param amount The amount to transfer.
   */
  function ZOCSATransfer(address caller, address from, address to, uint256 amount) external;

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
  function ZOCSAGetCollectionInfos() external view returns (ZOCSAInfos memory);

  /**
    * @dev Returns all OCSAs collections deployed.
    */
  function ZOCSAGetAllCollections() external view returns (address[] memory);

  /**
   * @dev Returns the project description of the token.
   */
  function ZOCSADescription() external view returns (string memory);

  /**
   * @dev Get this collection project reward rate.
   */
  function ZOCSACollectionRewardRate() external view returns (uint256);

  /**
   * @dev Get the max supply of this OCSA collection.
   */
  function ZOCSAMaxSupply() external view returns (uint256);

  /**
   * @dev Get the total Bounded OCSA Supply of this OCSA collection.
   */
  function ZOCSABoundedSupply() external view returns (uint256);

  /**
   * @dev Get the total Unbounded OCSA Supply of this OCSA collection.
   */
  function ZOCSAUnboundedSupply() external view returns (uint256);

  /**
   * @dev Returns the reward balance for this collection by this user (all ocsas earnings) 
   * @param owner The owner address.
   */
  function ZOCSARewardBalanceOf(address owner) external view returns (uint256);

  /**
   * @dev Returns the address of the reward token paid by the protocol
   */
  function ZOCSARewardToken() external view returns (address);

  /**
   * @dev Returns the bounded ocsa balance of this user 
   * @param owner The owner address.
   */
  function ZOCSABoundedBalanceOf(address owner) external view returns (uint256);

  /**
   * @dev Returns the unbounded ocsa balance of this user 
   * @param owner The owner address.
   */
  function ZOCSAUnboundedBalanceOf(address owner) external view returns (uint256);
  /**
   * @dev Returns the total dividend available to user in the collection
   */
  function ZOCSAGetAvailableDividends() external view returns (uint256 amount);

  /**
   * @dev Returns the cost for one OCSA in this collection
   */
  function ZOCSAGetOCSAPrice() external view returns (uint256 amount);

  /**
   * @dev Allow user to withdraw their earning 
   */
	function ZOCSAWithdrawUserEarnings(address from, address to, uint256 amount) external;
  
  /**
   * @notice Bound OCSA to actual owner, which activate the income generating property of OCSA
   * @param amount The amount of OCSA to bound to actual owner.
  */
  function ZOCSABoundOCSA(address user, uint256 amount) external;
}
