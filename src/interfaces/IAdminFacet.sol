// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ZOCSATokenConfig } from "../shared/Structs.sol";

/**
 * @dev ERC721 diamond facet interface.
 */
interface IAdminFacet {  
  /**
   * @dev Sets the treasury address.
   * @param treasury The address to set as the treasury.
   */
  function setTreasuryAddress(address treasury) external;

  /**
   * @dev Sets the address of the admin minter.
   * @param newMinter The address to set as the admin minter.
   */

  function setAdminMinterAddress(address newMinter) external;

  /**
   * @dev Sets the address for the OCSA Marketplace.
   * @param OCSAMarketplace The address to set for the OCSA Marketplace.
   */
  function setOCSAMarketplaceAddress(address OCSAMarketplace) external;

  /**
   * @dev Mints new ZOCSA tokens.
   * @param token The token address for minting.
   * @param to The address to mint tokens to.
   * @param count The number of tokens to mint.
   */
  function ZOCSAMint(address token, address to, uint256 count) external;
  
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
}
