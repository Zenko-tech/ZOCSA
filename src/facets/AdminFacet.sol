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
  function setDiamondTreasuryAddress(address treasury) external isDiamondAdmin() {
    require (treasury != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.treasury = treasury;
  }

  /**
   * @dev add Diamond Admin privilege to this address.
   * @param newAdmin The address to set as the admin.
   */
  function addNewDiamondAdmin(address newAdmin) external isDiamondAdmin() {
    require (newAdmin != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.diamondAdmins[newAdmin] = true;
  }

  /**
   * @dev remove Diamond Admin privilege to this address.
   * @param admin The address to set as the admin.
   */
  function removeDiamondAdmin(address admin) external isDiamondAdmin() {
    require (admin != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.diamondAdmins[admin] = false;
  }

  /**
   * @dev Sets the address for the OCSA Marketplace.
   * @param OCSAMarketplace The address to set for the OCSA Marketplace.
   */
  function setOCSAMarketplaceAddress(address OCSAMarketplace) external isDiamondAdmin() {
    require (OCSAMarketplace != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.OCSAMarketplace = OCSAMarketplace;
  }
}