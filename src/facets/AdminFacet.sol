// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// import { ERC20 } from "../facades/ERC20.sol";
import { ZOCSAToken, ZOCSATokenConfig } from "../shared/Structs.sol";
import { ZOCSA } from "../facades/ZOCSA.sol";
import { LibZOCSA } from "../libs/LibZOCSA.sol";
import { IAdminFacet } from "../interfaces/IAdminFacet.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { AppStorage, LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

error ZOCSAInvalidInput();

contract AdminFacet is IAdminFacet, AccessControl {  

  /*
    Global Diamond settings
  */

  /**
   * @dev Sets the treasury address.
   * @param treasury The address to set as the treasury.
   */
  function setTreasuryAddress(address treasury) external isAdmin() {
    require (treasury != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.treasury = treasury;
  }

  /**
   * @dev Sets the address of the admin minter.
   * @param newMinter The address to set as the admin minter.
   */
  function setAdminMinterAddress(address newMinter) external isAdmin() {
    require (newMinter != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.adminMinter = newMinter;
  }

  /**
   * @dev Sets the address for the OCSA Marketplace.
   * @param OCSAMarketplace The address to set for the OCSA Marketplace.
   */
  function setOCSAMarketplaceAddress(address OCSAMarketplace) external isAdmin() {
    require (OCSAMarketplace != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.OCSAMarketplace = OCSAMarketplace;
  }

  /*
    Zenko OCSA settings
  */

  /**
   * @dev Mints new ZOCSA tokens.
   * @dev Only Zenko Admin Wallet can mint nft after KYC / Legal Contract / Payment Received
   * @param token The token address for minting.
   * @param to The address to mint tokens to.
   * @param count The number of tokens to mint.
   */
  function ZOCSAMint(address token, address to, uint256 count) external isAdminMinter() {
    LibZOCSA.mint(token, to, count);
  }

  /**
   * @dev Updates the project description for a ZOCSA token.
   * @param token The token address to update.
   * @param newDescription The new description string.
   */
  function ZOCSAUpdateProjectDescription(address token, string memory newDescription) external isAdmin() {
    if (LibString.len(newDescription) == 0) {
      revert ZOCSAInvalidInput();
    }
    ZOCSAToken storage t = LibAppStorage.diamondStorage().zOcsas[token];
    t.description = newDescription;
  }

  /**
   * @dev Dispatches user rewards for a ZOCSA token.
   * @param token The token address for which to dispatch rewards.
   * @param amount The amount of rewards to dispatch.
   */
  function ZOCSADispatchUserReward(address token, uint256 amount) external isAdmin() {
    if (amount == 0) {
      revert ZOCSAInvalidInput();
    }
    LibZOCSA.dispatchProjectReward(token, msg.sender, amount);
  }
  

}