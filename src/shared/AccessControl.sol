// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";
import { MetaContext } from "./MetaContext.sol";
import { LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

/**
  * @dev Caller/sender must be admin / contract owner.
  */
error CallerMustBeAdminError();


/**
 * @dev Access control module.
 */
abstract contract AccessControl is MetaContext {
  modifier isAdmin() {
    if (LibDiamond.contractOwner() != _msgSender()) {
      revert CallerMustBeAdminError();
    }
    _;
  }

  modifier isAdminMinter() {
    if (LibAppStorage.diamondStorage().adminMinter != _msgSender()) {
      revert CallerMustBeAdminError();
    }
    _;
  }

  modifier onlyZOCSAFacades() {
    if (LibAppStorage.diamondStorage().zOcsaApprovedFacades[_msgSender()] != true) {
      revert CallerMustBeAdminError();
    }
    _;
  }
}