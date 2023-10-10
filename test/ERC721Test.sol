// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { ERC721 } from "src/facades/ERC721.sol";

import { Vm } from "forge-std/Vm.sol";
import { TestBaseContract, console2 } from "./utils/TestBaseContract.sol";
import "../src/facets/ERC721Facet.sol";
import "../src/libs/LibERC721.sol";
import "../src/shared/AccessControl.sol";
import { LibString } from "../src/libs/LibString.sol";
import { ERC721Infos } from "../src/shared/Structs.sol";

contract ERC721Test is TestBaseContract {

  uint256 rewardPerToken;
  ERC721 token;

  function setUp() public virtual override {
    super.setUp();
    // console2.log("super.setup() deployed ");
  }

  function _getBal(uint256 amountInGwei, uint256 decimals) internal returns(uint256)
  {
    return amountInGwei / (10 ** decimals);
  }

  function _deployFacade(uint256 _maxSupply) internal {
    token = ERC721(address(diamond.erc721DeployToken(
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      _maxSupply, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    )));
    testERC20.approve(address(diamond), type(uint256).max);
  }

  function testDeployFacadeSucceeds() public {
    vm.recordLogs();
    diamond.erc721DeployToken(
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      5000, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    Vm.Log[] memory entries = vm.getRecordedLogs();
    // console2.log(entries[0].topics.length);
    // assertEq(entries.length, 2, "Invalid entry count");
    // assertEq(entries[1].topics.length, 1, "Invalid event count");
    // assertEq(
    //     entries[1].topics[0],
    //     keccak256("ERC721NewToken(address)"),
    //     "Invalid event signature"
    // );
        assertEq(
        entries[0].topics[0],
        keccak256("ERC721NewToken(address)"),
        "Invalid event signature"
    );
    (address t) = abi.decode(entries[0].data, (address));

    ERC721 temp = ERC721(t);

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
    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "TEST", // symbol
      "", //description 
      "http://",  //baseUri
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "",  //baseUri
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      0, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      100, //maxSupply
      0, //collectionRewardRate
      1, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      100, //maxSupply
      10, //collectionRewardRate
      0, // tokenPrice 
      address(testERC20) // rewardToken 
    );

    vm.expectRevert( abi.encodePacked(ERC721InvalidInput.selector) );
    diamond.erc721DeployToken(      
      "Test Collection", // name
      "TEST", // symbol
      "Test Project Description", //description 
      "http://",  //baseUri
      100, //maxSupply
      10, //collectionRewardRate
      1, // tokenPrice 
      address(0) // rewardToken 
    );

  }


  function testUrisAreValid() public {
    uint256 maxSupply = 100; 
    _deployFacade(maxSupply);

    for (uint256 i = 1; i <= maxSupply; i++) {
        vm.startPrank(adminMinter);
        diamond.erc721Mint(address(token), account0, 1);
        vm.stopPrank();

        string memory expectedUri = string(abi.encodePacked("http://", LibString.toString(i)));
        assertEq(token.tokenURI(i), expectedUri);
    }
}

  function testAllCollectionsInfos() public {
    _deployFacade(100);
    _deployFacade(100);
    ERC721Infos[] memory datas = diamond.erc721GetAllCollectionsInfos();
    assertEq(datas.length, 2, "Error lengths mismatch");
    assertEq(datas[0].name, "Test Collection", "Invalid name");
    assertEq(datas[1].name, "Test Collection", "Invalid name");
  }

  function testUriShouldRevert() public {
    _deployFacade(100);

    vm.expectRevert("ERC721: invalid token ID");
    token.tokenURI(101);
  }

  function testSupplyDispatch() public {
    _deployFacade(100);
    
    // first test with 70 max supply : only proportionnal amount should be withdrawn from admin
    vm.startPrank(adminMinter);
    diamond.erc721Mint(address(token), account0, 40);
    diamond.erc721Mint(address(token), account1, 20);
    diamond.erc721Mint(address(token), account2, 10);
    vm.stopPrank();

    uint256 balBefore = testERC20.balanceOf(admin);
    diamond.erc721DispatchUserReward(address(token), 100e18);
    uint256 balAfter = testERC20.balanceOf(admin);

    rewardPerToken = 100e18 / 100;
    // console2.log(balBefore, balAfter);
    assertEq(balAfter, balBefore - (rewardPerToken * 70), "Invalid Admin Balance");


    // test with full supply : full amount withdraw + stored remainder
    vm.startPrank(adminMinter);
    diamond.erc721Mint(address(token), account2, 30);
    vm.stopPrank();

    balBefore = testERC20.balanceOf(admin);
    diamond.erc721DispatchUserReward(address(token), 100e18);
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
    diamond.erc721Mint(address(token), account0, 1);
    diamond.erc721Mint(address(token), account1, 1);
    diamond.erc721Mint(address(token), account2, 1);
    vm.stopPrank();

    diamond.erc721DispatchUserReward(address(token), 100e18);
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
    diamond.erc721Mint(address(token), account0, 1);
    diamond.erc721Mint(address(token), account0, 1);

    diamond.erc721Mint(address(token), account1, 1);
    diamond.erc721Mint(address(token), account2, 1);
    vm.stopPrank();

    diamond.erc721DispatchUserReward(address(token), 100e18);
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
  - user 0 mint 1 nft
  - user 1 mint 1 nft
  - user 2 mint 1 nft
  Admin dispath 100usdc reward
  - user 0 mint + 1 nft (2)
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
    diamond.erc721Mint(address(token), account0, 1);
    diamond.erc721Mint(address(token), account1, 1);
    diamond.erc721Mint(address(token), account2, 1);
    vm.stopPrank();

    diamond.erc721DispatchUserReward(address(token), 100e18);
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
    diamond.erc721Mint(address(token), account0, 1);
    vm.stopPrank();
    // console2.log("2 Rewards Balances : ", 
    //   token.rewardBalanceOf(account0), 
    //   token.rewardBalanceOf(account1), 
    //   token.rewardBalanceOf(account2) 
    // );

    diamond.erc721DispatchUserReward(address(token), 100e18);

    assertEq(token.balanceOf(account0), 2, "Invalid balance");
    assertEq(token.balanceOf(account1), 1, "Invalid balance");
    assertEq(token.balanceOf(account2), 1, "Invalid balance");
    assertEq(token.totalSupply(), 4, "Invalid total supply");
    assertNotEq(token.rewardBalanceOf(account0), 0, "Reward Balance shouldnt be empty !");
    assertEq(token.rewardBalanceOf(account0), (token.rewardBalanceOf(account1) + (token.rewardBalanceOf(account2) / 2)), "Invalid Reward balance");
    assertEq(token.rewardBalanceOf(account1), token.rewardBalanceOf(account2), "Invalid Reward balance");

    diamond.erc721DispatchUserReward(address(token), 100e18);

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
    diamond.erc721Mint(address(token), account0, 1);
    vm.stopPrank();

    diamond.erc721DispatchUserReward(address(token), 100e18);

    assertEq(testERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");

    assertEq(testERC20.balanceOf(account1), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account1), 18), 0, "Avalaible reward balance should be 1");

    vm.startPrank(account1);
    vm.expectRevert(bytes("No enough dividends to withdraw"));
    token.withdrawUserReward(account1, 1);
    vm.stopPrank();

    assertEq(testERC20.balanceOf(account1), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account1), 18), 0, "Avalaible reward balance should be 1");

  }

  function testShouldntBeAbleToWithdrawFromFacet() public {
    _deployFacade(100);

    vm.startPrank(adminMinter);
    diamond.erc721Mint(address(token), account0, 1);
    vm.stopPrank();

    diamond.erc721DispatchUserReward(address(token), 100e18);

    assertEq(testERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");

    vm.startPrank(account0);
    vm.expectRevert(CallerMustBeAdminError.selector);
    diamond.erc721WithdrawUserEarnings(address(token), account0, account1, 1);
    vm.stopPrank();

    assertEq(testERC20.balanceOf(account0), 0, "Reward balance should be empty");
    assertEq(_getBal(token.rewardBalanceOf(account0), 18), 1, "Avalaible reward balance should be 1");
  }

  function testShouldntBeAbleToMintMaxSupply() public {
    _deployFacade(5000);

    vm.startPrank(adminMinter);
    diamond.erc721Mint(address(token), account0, 5000);
    
    assertEq(token.balanceOf(account0), 5000, "invalid asset balance");
    vm.expectRevert(bytes("ERC721: Cannot mint new Nft, max supply reached"));
    diamond.erc721Mint(address(token), account1, 1);
    vm.stopPrank();
  }

    function testShouldntBeAbleToMintNonAdmin() public {
    _deployFacade(100);
    
    vm.startPrank(account0);
    // vm.expectRevert(abi.encodePacked(CallerMustBeAdminError.selector));
    vm.expectRevert(CallerMustBeAdminError.selector);
    diamond.erc721Mint(address(token), account0, 1);
    vm.stopPrank();

  }

  function testShouldntBeAbleToMintContractNonReceiver() public {
    _deployFacade(100);
    
    vm.startPrank(adminMinter);
    // vm.expectRevert(abi.encodePacked(CallerMustBeAdminError.selector));
    vm.expectRevert(bytes("ERC721: transfer to non ERC721Receiver implementer"));
    diamond.erc721Mint(address(token), address(testERC20), 1);
    vm.stopPrank();

  }
}
