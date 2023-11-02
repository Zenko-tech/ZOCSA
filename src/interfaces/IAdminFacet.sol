// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/**
 * @dev ERC721 diamond facet interface.
 */
interface IAdminFacet {  
  /**
   * @dev Sets the treasury address.
   * @param treasury The address to set as the treasury.
   */
  function setDiamondTreasuryAddress(address treasury) external;

  /**
   * @dev add Diamond Admin privilege to this address.
   * @param newAdmin The address to set as the admin.
   */
  function addNewDiamondAdmin(address newAdmin) external;

  /**
   * @dev remove Diamond Admin privilege to this address.
   * @param admin The address to set as the admin.
   */
  function removeDiamondAdmin(address admin) external;
  
  /**
   * @dev Sets the address for the OCSA Marketplace.
   * @param OCSAMarketplace The address to set for the OCSA Marketplace.
   */
  function setOCSAMarketplaceAddress(address OCSAMarketplace) external;

  /**
   * @dev Updates the project description for a ZOCSA token.
   * @param token The token address to update.
   * @param newDescription The new description string.
   */
  function ZOCSAUpdateProjectDescription(address token, string memory newDescription) external;

  /**
   * @dev Dispatches user rewards for a ZOCSA token.
   * @param token The token address for which to dispatch rewards.
   * @param amount The amount of rewards to dispatch.
   */
  function ZOCSADispatchUserReward(address token, uint256 amount) external;

  /**
   * @dev Change transfer status of specific ocsa collection.
   * @param token The token address for which to change transfer status.
   * @param status the transfer status to update.
   */
  function ZOCSAUpdateTransferStatus(address token, bool status) external;
}
