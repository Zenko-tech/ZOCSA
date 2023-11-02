// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";
import { MetaContext } from "./MetaContext.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

/**
  * @dev Caller/sender must be admin / contract owner.
  */
error CallerMustBeAdminError();


/**
 * @dev Access control module.
 */
abstract contract AccessControl is MetaContext {
  modifier isDiamondAdmin() {
    if (LibDiamond.contractOwner() != _msgSender() && LibAppStorage.diamondStorage().diamondAdmins[_msgSender()] == false ) {
      revert CallerMustBeAdminError();
    }
    _;
  }

  modifier onlyZOCSAFacades() {
    if (LibAppStorage.diamondStorage().zOcsaApprovedFacades[_msgSender()] == false) {
      revert CallerMustBeAdminError();
    }
    _;
  }
}