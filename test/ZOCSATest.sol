// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { ZOCSA } from "src/facades/ZOCSA.sol";

import { Vm } from "forge-std/Vm.sol";
import { TestBaseContract, console2, console } from "./utils/TestBaseContract.sol";
import "../src/facets/ZOCSAFacet.sol";
import "../src/libs/LibZOCSA.sol";
import "../src/shared/AccessControl.sol";
import { LibString } from "../src/libs/LibString.sol";
import { ZOCSAInfos, ZOCSATokenConfig, ZOCSACheckpoint } from "../src/shared/Structs.sol";
import { ERC20TestContract } from "testing_contracts/ERC20TestContract.sol";

contract ZOCSATest is TestBaseContract {

  uint256 rewardPerToken;
  ZOCSA token;
  address[] emptyAddrArr = new address[](0);
  ERC20TestContract public tERC20;

/* -------------------------------------------------------------------------- */
/*                                    Utils                                   */
/* -------------------------------------------------------------------------- */

  function setUp() public virtual override {
    super.setUp();
    tERC20 = new ERC20TestContract(admin, 10000000e18);
    tERC20.transfer(adminMinter, 6000e18); // use adminMinter to keep clean accounts balances to simplify testing 
    // tERC20.transfer(account0, 1000e18);
    // tERC20.transfer(account1, 1000e18);
    // tERC20.transfer(account2, 1000e18);
    // tERC20.transfer(account3, 1000e18);
    vm.startPrank(adminMinter);
    tERC20.approve(address(diamond), type(uint256).max);
    vm.stopPrank();
  }

  function _getBal(uint256 amountInGwei, uint256 decimals) internal returns(uint256)
  {
    return amountInGwei / (10 ** decimals);
  }

  function _deployFacade(uint256 _maxSupply) internal {
    token = ZOCSA(address(diamond.ZOCSADeployToken(ZOCSATokenConfig(
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      _maxSupply, //maxSupply
      10, //collectionRewardRate
      1 ether, // tokenPrice = 1e18
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ))));
    // admin reward dispatcher Approve Diamond with max bal to ease testing 
    tERC20.approve(address(diamond), type(uint256).max);
    // whitelist 3 users simulating KYC / Bounded OCSA
    address[] memory _whitelistAddresses = new address[](3);
    _whitelistAddresses[0] = account0;
    _whitelistAddresses[1] = account1;
    _whitelistAddresses[2] = account2;
    diamond.addAddressesToWhitelist(1, _whitelistAddresses);
  }

  /* -------------------------------------------------------------------------- */
  /*                         Test Deploy Diamond Collections                    */
  /* -------------------------------------------------------------------------- */

  function testAllCollectionsInfos() public {
    _deployFacade(100);
    _deployFacade(100);
    ZOCSAInfos[] memory datas = diamond.ZOCSAGetAllCollectionsInfos();
    assertEq(datas.length, 2, "Error lengths mismatch");
    assertEq(datas[0].name, datas[1].name, "Invalid name");
  }

  function testDeployFacadeSucceeds() public {
    vm.recordLogs();
    diamond.ZOCSADeployToken(ZOCSATokenConfig(
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      5000, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    Vm.Log[] memory entries = vm.getRecordedLogs();
    // console2.log(entries[0].topics.length);
    // assertEq(entries.length, 2, "Invalid entry count");
    // assertEq(entries[1].topics.length, 1, "Invalid event count");
    // assertEq(
    //     entries[1].topics[0],
    //     keccak256("ZOCSANewToken(address)"),
    //     "Invalid event signature"
    // );
        assertEq(
        entries[0].topics[0],
        keccak256("ZOCSANewToken(address)"),
        "Invalid event signature"
    );
    (address t) = abi.decode(entries[0].data, (address));

    ZOCSA temp = ZOCSA(t);
    ZOCSAInfos memory infos = temp.getCollectionInfos();
    assertEq(infos.collectionAddress, address(temp), "Invalid address");
    assertEq(infos.name, "Test Collection", "Invalid name");
    assertEq(infos.symbol, "TEST", "Invalid symbol");
    assertEq(infos.description, "Test Project Description", "Invalid description");
    assertEq(infos.whitelistId, 1, "Invalid whitelist (should be Zenko global whitelist 1)");
    assertEq(infos.totalSupply, 0, "Invalid total Supply");
    assertEq(infos.maxSupply, 5000, "Invalid max Supply");
    assertEq(infos.totalUnboundedOcsa, 0, "Invalid unbounded Supply");
    assertEq(infos.totalBoundedOcsa, 0, "Invalid bounded Supply");
    assertEq(infos.collectionRewardRate, 10, "Invalid OCSA collection reward rate");
    assertEq(infos.individualShare , ((10 * 1e18) / 5000), "Invalid OCSA individual share");
    assertEq(infos.tokenPrice, 1, "Invalid OCSA price");
    assertEq(infos.rewardToken, address(tERC20), "Invalid reward token address");
    assertEq(infos.collectionTreasury, accountTreasury, "Invalid treasury address");
    assertEq(infos.actualCheckpointsIndex, 0, "Invalid checkpoint index");
    assertEq(infos.leftoverReward, 0, "Invalid leftover reward");
  }

  function testDeployFacadeFails() public {
    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr    
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      0, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      0, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      0, // tokenPrice 
      address(tERC20), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(0), // rewardToken
      accountTreasury, // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(tERC20), // rewardToken
      address(0), // collection treasury address 
      emptyAddrArr,
      emptyAddrArr
    ));

  }

  function testAddAdmin() public {
    diamond.addNewDiamondAdmin(account1);
    vm.startPrank(account1);
    diamond.addNewDiamondAdmin(account2);
    vm.stopPrank();
  }


/* -------------------------------------------------------------------------- */
/*                               Test OCSA Mint                               */
/* -------------------------------------------------------------------------- */

  function testShouldBeAbleToMint() public {
    _deployFacade(100);
    address[] memory _whitelistAddresses = new address[](1);
    _whitelistAddresses[0] = account3;
    diamond.addAddressesToWhitelist(1, _whitelistAddresses);
    tERC20.transfer(account3, 100e18);
    vm.startPrank(account3);
    tERC20.approve(address(diamond), type(uint256).max);
    token.mint(account3, 2);
    vm.stopPrank();

    assertEq(token.balanceOf(account3), 2, "incorrect balance");
    assertEq(token.boundedBalanceOf(account3), 2, "incorrect balance");
    assertEq(token.unboundedBalanceOf(account3), 0, "incorrect balance");

  }

  function testShouldntBeAbleToMintMaxSupply() public {
    _deployFacade(5000);

    vm.startPrank(adminMinter);
    token.mint(account0, 5000);
    
    assertEq(token.balanceOf(account0), 5000, "invalid asset balance");
    vm.expectRevert(bytes("ZOCSA: Cannot mint new OCSA, max supply reached"));
    token.mint(account1, 1);
    vm.stopPrank();
  }

  function testShouldntBeAbleToMintNotEnoughFundsorAllowance() public {
    _deployFacade(100);
    
    vm.startPrank(account0);
    // vm.expectRevert(abi.encodePacked(CallerMustBeAdminError.selector));
    // vm.expectRevert(CallerMustBeAdminError.selector);
    vm.expectRevert(bytes("ERC20: insufficient allowance"));
    token.mint(account0, 1);

    tERC20.approve(address(diamond), type(uint256).max);
    vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
    token.mint(account0, 1);
    vm.stopPrank();
  }

  function testShouldntBeAbleToMintRecipientNotWhiteListed() public {
    _deployFacade(100);
    
    vm.startPrank(adminMinter);
    vm.expectRevert(bytes("ZOCSA: Recipient not whitelisted !"));
    token.mint(account3, 1);
    vm.stopPrank();
  }

  // function testShouldntBeAbleToMintContractNonReceiver() public {
  //   _deployFacade(100);
    
  //   vm.startPrank(adminMinter);
  //   // vm.expectRevert(abi.encodePacked(CallerMustBeAdminError.selector));
  //   vm.expectRevert(bytes("ZOCSA: transfer to non ZOCSAReceiver implementer"));
  //   token.mint(address(tERC20), 1);
  //   vm.stopPrank();

  // }

/* -------------------------------------------------------------------------- */
/*                       Test OCSA Admin Dispatch Reward                      */
/* -------------------------------------------------------------------------- */
  function testDispatchRewards() public {
    _deployFacade(100);
    
    // first test with 70 max supply : only proportionnal amount should be withdrawn from admin
    vm.startPrank(adminMinter);
    token.mint(account0, 40);
    token.mint(account1, 20);
    token.mint(account2, 10);
    vm.stopPrank();
    uint256 balBefore = tERC20.balanceOf(admin);
    token.dispatchUserReward(100e18);
    uint256 balAfter = tERC20.balanceOf(admin);
    rewardPerToken = 100e18 / 100;
    // console2.log(balBefore, balAfter);
    assertEq(balAfter, balBefore - (rewardPerToken * 70), "Invalid Admin Balance");
    assertEq(token.rewardBalanceOf(account0), 40e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account1), 20e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account2), 10e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account3), 0, "Invalid Reward balance");

    // test with full supply : full amount withdraw + stored remainder
    vm.startPrank(adminMinter);
    token.mint(account2, 30);
    vm.stopPrank();
    balBefore = tERC20.balanceOf(admin);
    token.dispatchUserReward(100e18);
    balAfter = tERC20.balanceOf(admin);
    // console2.log(balBefore, balAfter);
    assertEq(balAfter, balBefore - 100e18, "Invalid Admin Balance");
    assertEq(token.rewardBalanceOf(account0), 80e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account1), 40e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account2), 50e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account3), 0, "Invalid Reward balance");

    // test with full supply minted but unbounded (not supposed to dispatch reward)
    vm.startPrank(account0);
    token.transfer(account3, 40);
    vm.stopPrank();
    vm.startPrank(account1);
    token.transfer(account3, 20);
    vm.stopPrank();
    vm.startPrank(account2);
    token.transfer(account3, 40);
    vm.stopPrank();
    balBefore = tERC20.balanceOf(admin);
    token.dispatchUserReward(100e18);
    balAfter = tERC20.balanceOf(admin);
    // console2.log(balBefore, balAfter);
    assertEq(balAfter, balBefore, "Invalid Admin Balance");
    assertEq(token.rewardBalanceOf(account0), 80e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account1), 40e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account2), 50e18, "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account3), 0, "Invalid Reward balance");
    assertEq(token.totalSupply(), 100, "Invalid total supply");
    assertEq(token.boundedSupply(), 0, "Invalid total bounded supply");
    assertEq(token.unboundedSupply(), 100, "Invalid total unbounded supply");
    assertEq(token.balanceOf(account0), 0, "Invalid user balance");
    assertEq(token.balanceOf(account1), 0, "Invalid user balance");
    assertEq(token.balanceOf(account2), 0, "Invalid user balance");
    assertEq(token.balanceOf(account3), 100, "Invalid user balance");
    assertEq(token.boundedBalanceOf(account0), 0, "Invalid user bounded balance");
    assertEq(token.boundedBalanceOf(account1), 0, "Invalid user bounded balance");
    assertEq(token.boundedBalanceOf(account2), 0, "Invalid user bounded balance");
    assertEq(token.boundedBalanceOf(account3), 0, "Invalid user bounded balance");
    assertEq(token.unboundedBalanceOf(account0), 0, "Invalid user unbounded balance");
    assertEq(token.unboundedBalanceOf(account1), 0, "Invalid user unbounded balance");
    assertEq(token.unboundedBalanceOf(account2), 0, "Invalid user unbounded balance");
    assertEq(token.unboundedBalanceOf(account3), 100, "Invalid user unbounded balance");
  }
  // function testCheckpointsPricePerToken() public {
  //   _deployFacade(5000);
  //   token.dispatchUserReward(10920e18);
    
  //   ZOCSACheckpoint[] memory infos = token.getCollectionCheckpoints();
  //   assertEq(infos[0].rewardPerToken, 0, "HMM");
  //   // console.log(token.getCollectionCheckpoints(), token.getCollectionCheckpoints());
  // }
  /* -------------------------------------------------------------------------- */
  /*                       Test OCSA User Reward Withdraw                       */
  /* -------------------------------------------------------------------------- */

  function testWithdraw() public {
    testDispatchRewards();

    vm.startPrank(account0);
    token.withdrawUserReward(account0, token.rewardBalanceOf(account0));
    vm.stopPrank();
    vm.startPrank(account1);
    token.withdrawUserReward(account1, token.rewardBalanceOf(account1));
    vm.stopPrank();
    vm.startPrank(account2);  
    token.withdrawUserReward(account2, token.rewardBalanceOf(account2));
    vm.stopPrank();

    assertEq(tERC20.balanceOf(account0), 80e18, "Invalid user reward balance");
    assertEq(tERC20.balanceOf(account1), 40e18, "Invalid user reward balance");
    assertEq(tERC20.balanceOf(account2), 50e18, "Invalid user reward balance");
  }

  function testShouldntBeAbleToWithdrawNoShares() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    token.mint(account0, 1);
    vm.stopPrank();

    token.dispatchUserReward(100e18);

    assertEq(tERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");

    assertEq(tERC20.balanceOf(account1), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account1), 18), 0, "Avalaible reward balance should be 1");

    vm.startPrank(account1);
    vm.expectRevert(bytes("ZOCSA: No enough dividends to withdraw"));
    token.withdrawUserReward(account1, 1);
    vm.stopPrank();

    assertEq(tERC20.balanceOf(account1), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account1), 18), 0, "Avalaible reward balance should be 1");

  }

  function testShouldntBeAbleToWithdrawFromFacet() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    token.mint(account0, 1);
    vm.stopPrank();

    token.dispatchUserReward(100e18);

    assertEq(tERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");

    vm.startPrank(account0);
    vm.expectRevert(CallerMustBeAdminError.selector);
    diamond.ZOCSAWithdrawUserEarnings(address(token), account0, account1, 1);
    vm.stopPrank();

    assertEq(tERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");
  }
}
