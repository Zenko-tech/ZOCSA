// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibDiamond } from "lib/diamond-2-hardhat/contracts/libraries/LibDiamond.sol";
import { AppStorage, LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibWhitelist } from "../libs/LibWhitelist.sol";
import { Whitelist } from "../shared/Structs.sol";

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

    // Create the first and only Zenko ZOCSA WhiteList
    address[] memory emptArr = new address[](0);
    s.whitelist = Whitelist({ name: "Zenko OCSA Whitelist", addresses: emptArr });

    emit InitializeDiamond(msg.sender);
  }
}
