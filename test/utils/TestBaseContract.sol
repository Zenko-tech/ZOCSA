// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { IDiamondCut } from "lib/diamond-2-hardhat/contracts/interfaces/IDiamondCut.sol";
import { DiamondProxy } from "src/generated/DiamondProxy.sol";
import { IDiamondProxy } from "src/generated/IDiamondProxy.sol";
import { LibDiamondHelper } from "src/generated/LibDiamondHelper.sol";
import { InitDiamond } from "src/init/InitDiamond.sol";

abstract contract TestBaseContract is Test {
  address public immutable admin = address(this);
  address public adminMinter;
  address public accountTreasury;
  address public account0;
  address public account1;
  address public account2;
  address public account3;

  IDiamondProxy public diamond;

  function setUp() public virtual {
    // console2.log("\n -- Test Base\n");

    // console2.log("Test contract address, aka account0", address(this));
    // console2.log("msg.sender during setup", msg.sender);

    vm.label(admin, "Account admin");
    account0 = vm.addr(1);
    vm.label(account0, "Account 0");
    account1 = vm.addr(2);
    vm.label(account1, "Account 1");
    account2 = vm.addr(3);
    vm.label(account2, "Account 2");
    account3 = vm.addr(4);
    vm.label(account2, "Account 3");
    accountTreasury = vm.addr(5);
    vm.label(accountTreasury, "Account Treasury");
    adminMinter = vm.addr(6);
    vm.label(adminMinter, "Account AdminMinter");

    // console2.log("Deploy diamond");
    diamond = IDiamondProxy(address(new DiamondProxy(admin)));

    // console2.log("Cut and init");
    IDiamondCut.FacetCut[] memory cut = LibDiamondHelper.deployFacetsAndGetCuts();
    InitDiamond init = new InitDiamond();
    diamond.diamondCut(cut, address(init), abi.encodeWithSelector(init.init.selector, accountTreasury));
  }
}
