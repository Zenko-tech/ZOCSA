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
}
