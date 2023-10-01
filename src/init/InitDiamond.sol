// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage, LibAppStorage } from "../libs/LibAppStorage.sol";

error DiamondAlreadyInitialized();

contract InitDiamond {
  event InitializeDiamond(address sender);

  function init(address _treasury, address _adminMinter) external {
    AppStorage storage s = LibAppStorage.diamondStorage();
    if (s.diamondInitialized) {
      revert DiamondAlreadyInitialized();
    }
    s.diamondInitialized = true;

    /*
        TODO: add custom initialization logic here
    */
    s.treasury = _treasury;
    s.adminMinter = _adminMinter;

    emit InitializeDiamond(msg.sender);
  }
}
