// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";
import { AppStorage, LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibWhitelist } from "../libs/LibWhitelist.sol";

error DiamondAlreadyInitialized();

contract InitDiamond {
  event InitializeDiamond(address sender);

  function init(address _ZenkoTreasury) external {
    AppStorage storage s = LibAppStorage.diamondStorage();
    if (s.diamondInitialized) {
      revert DiamondAlreadyInitialized();
    }
    s.diamondInitialized = true;


    address contractAdmin = LibDiamond.contractOwner();
    s.treasury = _ZenkoTreasury;
    s.diamondAdmins[contractAdmin] = true;

    // Create the first and only Zenko ZOCSA WhiteList, when each POCSA has it own whitelist 
    address[] memory adminList = new address[](1);
    address[] memory whitelist = new address[](0);
    adminList[0] = contractAdmin;
    // name, admin addresses, whitelisted addresses, useZenkoKYC(onlyForPartner, no need for ZOCSA)
    LibWhitelist.createNewWhitelist("Zenko OCSA Whitelist", adminList, whitelist, false);

    emit InitializeDiamond(msg.sender);
  }
}
