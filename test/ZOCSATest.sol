// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { ZOCSA } from "src/facades/ZOCSA.sol";

import { Vm } from "forge-std/Vm.sol";
import { TestBaseContract, console2 } from "./utils/TestBaseContract.sol";
import "../src/facets/ZOCSAFacet.sol";
import "../src/libs/LibZOCSA.sol";
import "../src/shared/AccessControl.sol";
import { LibString } from "../src/libs/LibString.sol";
import { ZOCSAInfos, ZOCSATokenConfig } from "../src/shared/Structs.sol";

contract ZOCSATest is TestBaseContract {

  uint256 rewardPerToken;
  ZOCSA token;

  function setUp() public virtual override {
    super.setUp();
    // console2.log("super.setup() deployed ");
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
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    ))));
    testERC20.approve(address(diamond), type(uint256).max);
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
      address(testERC20) // rewardToken 
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

    assertEq(temp.name(), "Test Collection", "Invalid name");
    assertEq(temp.symbol(), "TEST", "Invalid symbol");
    assertEq(temp.description(), "Test Project Description", "Invalid description");
    assertEq(temp.maxSupply(), 5000, "Invalid max Supply");
    // TODO : WIP : struc infos token
    // assertEq(temp.description(), "Test Project Description", "Invalid description");
    // assertEq(temp.description(), "Test Project Description", "Invalid description");
    // assertEq(temp.description(), "Test Project Description", "Invalid description");
    // assertEq(temp.description(), "Test Project Description", "Invalid description");
    // // ... keep going ...


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
      address(testERC20) // rewardToken 
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      0, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      0, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      0, // tokenPrice 
      address(testERC20) // rewardToken 
    ));

    vm.expectRevert( abi.encodePacked(ZOCSAInvalidInput.selector) );
    diamond.ZOCSADeployToken(ZOCSATokenConfig(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(0) // rewardToken 
    ));

  }

  function testAllCollectionsInfos() public {
    _deployFacade(100);
    _deployFacade(100);
    ZOCSAInfos[] memory datas = diamond.ZOCSAGetAllCollectionsInfos();
    assertEq(datas.length, 2, "Error lengths mismatch");
    assertEq(datas[0].name, "Test Collection", "Invalid name");
    assertEq(datas[1].name, "Test Collection", "Invalid name");
  }


  function testSupplyDispatch() public {
    _deployFacade(100);
    
    // first test with 70 max supply : only proportionnal amount should be withdrawn from admin
    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 40);
    diamond.ZOCSAMint(address(token), account1, 20);
    diamond.ZOCSAMint(address(token), account2, 10);
    vm.stopPrank();

    uint256 balBefore = testERC20.balanceOf(admin);
    diamond.ZOCSADispatchUserReward(address(token), 100e18);
    uint256 balAfter = testERC20.balanceOf(admin);

    rewardPerToken = 100e18 / 100;
    // console2.log(balBefore, balAfter);
    assertEq(balAfter, balBefore - (rewardPerToken * 70), "Invalid Admin Balance");


    // test with full supply : full amount withdraw + stored remainder
    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account2, 30);
    vm.stopPrank();

    balBefore = testERC20.balanceOf(admin);
    diamond.ZOCSADispatchUserReward(address(token), 100e18);
    balAfter = testERC20.balanceOf(admin);

    // console2.log(balBefore, balAfter);
    assertEq(balAfter, balBefore - 100e18, "Invalid Admin Balance");
  }
  
  function testSimpleDistrib() public {
    _deployFacade(100);
    // console2.log("account 0 is :", account0, testERC20.balanceOf(account0));
    // console2.log("account 1 is :", account1, testERC20.balanceOf(account1));
    // console2.log("account 2 is :", account2, testERC20.balanceOf(account2));

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 1);
    diamond.ZOCSAMint(address(token), account1, 1);
    diamond.ZOCSAMint(address(token), account2, 1);
    vm.stopPrank();

    diamond.ZOCSADispatchUserReward(address(token), 100e18);
    rewardPerToken = 100e18 / 100;

    assertEq(token.balanceOf(account0), 1, "Invalid balance");
    assertEq(token.balanceOf(account1), 1, "Invalid balance");
    assertEq(token.balanceOf(account2), 1, "Invalid balance");
    assertEq(token.totalSupply(), 3, "Invalid total supply");
    assertNotEq(token.rewardBalanceOf(account0), 0, "Reward Balance shouldnt be empty !");
    assertEq(token.rewardBalanceOf(account0), token.rewardBalanceOf(account1), "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account0), token.rewardBalanceOf(account2), "Invalid Reward balance");

    // console2.log("Final Rewards Balances : ", 
    //   token.rewardBalanceOf(account0), 
    //   token.rewardBalanceOf(account1), 
    //   token.rewardBalanceOf(account2) 
    // );

    // console2.log("Protocol Balance : ", 
    //   testERC20.balanceOf(accountTreasury)

    // );
  }

  function testAsymetricDistrib() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 1);
    diamond.ZOCSAMint(address(token), account0, 1);

    diamond.ZOCSAMint(address(token), account1, 1);
    diamond.ZOCSAMint(address(token), account2, 1);
    vm.stopPrank();

    diamond.ZOCSADispatchUserReward(address(token), 100e18);
    rewardPerToken = 100e18 / 100;

    assertEq(token.balanceOf(account0), 2, "Invalid balance");
    assertEq(token.balanceOf(account1), 1, "Invalid balance");
    assertEq(token.balanceOf(account2), 1, "Invalid balance");
    assertEq(token.totalSupply(), 4, "Invalid total supply");
    assertNotEq(token.rewardBalanceOf(account0), 0, "Reward Balance shouldnt be empty !");
    assertEq(token.rewardBalanceOf(account0), (token.rewardBalanceOf(account1) + token.rewardBalanceOf(account2)), "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account1), token.rewardBalanceOf(account2), "Invalid Reward balance");

    // console2.log("Final Rewards Balances : ", 
    //   token.rewardBalanceOf(account0), 
    //   token.rewardBalanceOf(account1), 
    //   token.rewardBalanceOf(account2) 
    // );

    // console2.log("Protocol Balance : ", 
    //   testERC20.balanceOf(accountTreasury)

    // );
  }


  /* Scenario : 
  Token with 100 max supply
  - user 0 mint 1 ocsa
  - user 1 mint 1 ocsa
  - user 2 mint 1 ocsa
  Admin dispath 100usdc reward
  - user 0 mint + 1 ocsa (2)
  Admin dispath 100usdc reward
  - user 0 should have 3 usdc available
  - user 1 should have 2 usdc available
  - user 2 should have 2 usdc available
  Admin dispath 100usdc reward
  - user 0 should have 5 usdc available
  - user 1 should have 3 usdc available
  - user 2 should have 3 usdc available
  */
  function testDeepAsymetricDistrib() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 1);
    diamond.ZOCSAMint(address(token), account1, 1);
    diamond.ZOCSAMint(address(token), account2, 1);
    vm.stopPrank();

    diamond.ZOCSADispatchUserReward(address(token), 100e18);
    rewardPerToken = 100e18 / 100;
    assertNotEq(token.rewardBalanceOf(account0), 0, "Reward Balance shouldnt be empty !");
    assertEq(token.rewardBalanceOf(account0), token.rewardBalanceOf(account1), "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account0), token.rewardBalanceOf(account2), "Invalid Reward balance");

    // console2.log("1 Rewards Balances : ", 
    //   token.rewardBalanceOf(account0), 
    //   token.rewardBalanceOf(account1), 
    //   token.rewardBalanceOf(account2) 
    // );

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 1);
    vm.stopPrank();
    // console2.log("2 Rewards Balances : ", 
    //   token.rewardBalanceOf(account0), 
    //   token.rewardBalanceOf(account1), 
    //   token.rewardBalanceOf(account2) 
    // );

    diamond.ZOCSADispatchUserReward(address(token), 100e18);

    assertEq(token.balanceOf(account0), 2, "Invalid balance");
    assertEq(token.balanceOf(account1), 1, "Invalid balance");
    assertEq(token.balanceOf(account2), 1, "Invalid balance");
    assertEq(token.totalSupply(), 4, "Invalid total supply");
    assertNotEq(token.rewardBalanceOf(account0), 0, "Reward Balance shouldnt be empty !");
    assertEq(token.rewardBalanceOf(account0), (token.rewardBalanceOf(account1) + (token.rewardBalanceOf(account2) / 2)), "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account1), token.rewardBalanceOf(account2), "Invalid Reward balance");

    diamond.ZOCSADispatchUserReward(address(token), 100e18);

    // console2.log("Final last Rewards Balances : ", 
    //   _getBal(token.rewardBalanceOf(account0), 18), 
    //   _getBal(token.rewardBalanceOf(account1), 18), 
    //   _getBal(token.rewardBalanceOf(account2), 18) 
    // );

    // console2.log("Protocol Balance : ", 
    //   testERC20.balanceOf(accountTreasury)

    // );
    //0x76006C4471fb6aDd17728e9c9c8B67d5AF06cDA0
    //76006c4471fb6add17728e9c9c8b67d5af06cda0

  }

  function testSimpleWithdraw() public {
    testDeepAsymetricDistrib();

    vm.startPrank(account0);
    token.withdrawUserReward(account0, token.rewardBalanceOf(account0));
    vm.stopPrank();
    vm.startPrank(account1);
    token.withdrawUserReward(account1, token.rewardBalanceOf(account1));
    vm.stopPrank();
    vm.startPrank(account2);  
    token.withdrawUserReward(account2, token.rewardBalanceOf(account2));
    vm.stopPrank();


    // console2.log("testerc20 bals : ", 
    //   testERC20.balanceOf(account0),
    //   testERC20.balanceOf(account1),
    //   testERC20.balanceOf(account2)
    // );

    // console2.log("reward bals : ", 
    //   token.rewardBalanceOf(account0),
    //   token.rewardBalanceOf(account1),
    //   token.rewardBalanceOf(account2)
    // );
  }

  function testShouldntBeAbleToWithdrawNoShares() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 1);
    vm.stopPrank();

    diamond.ZOCSADispatchUserReward(address(token), 100e18);

    assertEq(testERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");

    assertEq(testERC20.balanceOf(account1), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account1), 18), 0, "Avalaible reward balance should be 1");

    vm.startPrank(account1);
    vm.expectRevert(bytes("ZOCSA: No enough dividends to withdraw"));
    token.withdrawUserReward(account1, 1);
    vm.stopPrank();

    assertEq(testERC20.balanceOf(account1), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account1), 18), 0, "Avalaible reward balance should be 1");

  }

  function testShouldntBeAbleToWithdrawFromFacet() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 1);
    vm.stopPrank();

    diamond.ZOCSADispatchUserReward(address(token), 100e18);

    assertEq(testERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");

    vm.startPrank(account0);
    vm.expectRevert(CallerMustBeAdminError.selector);
    diamond.ZOCSAWithdrawUserEarnings(account0, account1, 1);
    vm.stopPrank();

    assertEq(testERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");
  }

  function testShouldntBeAbleToMintMaxSupply() public {
    _deployFacade(5000);

    vm.startPrank(adminMinter);
    diamond.ZOCSAMint(address(token), account0, 5000);
    
    assertEq(token.balanceOf(account0), 5000, "invalid asset balance");
    vm.expectRevert(bytes("ZOCSA: Cannot mint new OCSA, max supply reached"));
    diamond.ZOCSAMint(address(token), account1, 1);
    vm.stopPrank();
  }

    function testShouldntBeAbleToMintNonAdmin() public {
    _deployFacade(100);
    
    vm.startPrank(account0);
    // vm.expectRevert(abi.encodePacked(CallerMustBeAdminError.selector));
    vm.expectRevert(CallerMustBeAdminError.selector);
    diamond.ZOCSAMint(address(token), account0, 1);
    vm.stopPrank();

  }

  // function testShouldntBeAbleToMintContractNonReceiver() public {
  //   _deployFacade(100);
    
  //   vm.startPrank(adminMinter);
  //   // vm.expectRevert(abi.encodePacked(CallerMustBeAdminError.selector));
  //   vm.expectRevert(bytes("ZOCSA: transfer to non ZOCSAReceiver implementer"));
  //   diamond.ZOCSAMint(address(token), address(testERC20), 1);
  //   vm.stopPrank();

  // }
}
