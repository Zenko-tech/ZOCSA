// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "../shared/Structs.sol";

struct AppStorage {
  bool diamondInitialized;
  uint256 reentrancyStatus;
  MetaTxContextStorage metaTxContext;
  /*
    OCSA Data Storage
  */
  // All deployed OCSAs Collection addresses
  address[] zOcsaCollections;
  // OCSA collection address => OCSA collection info
  mapping(address => ZOCSAToken) zOcsas;
  // register all OCSA contract for access rights
  mapping(address => bool) zOcsaApprovedFacades;
  /*
    WhiteList Data Storage
  */
  Whitelist whitelist;
  // If zero, then the user is not whitelisted. Otherwise, this represents the position of the user in the whitelist + 1
  mapping(address => uint256) isWhitelisted; // userAddress => isWhitelisted
  /*
    Diamond Global Data Storage
  */
  // zenko wallet
  address treasury;
  // mapping of zenko diamond admin address
  mapping(address => bool) diamondAdmins;
  // only plateforme to resell ocsa
  address OCSAMarketplace;

  /*
    NOTE: Once contracts have been deployed you cannot modify the existing entries here. You can only append 
    new entries. Otherwise, any subsequent upgrades you perform will break the memory structure of your 
    deployed contracts.
    */
}

library LibAppStorage {
  bytes32 internal constant DIAMOND_APP_STORAGE_POSITION = keccak256("diamond.app.storage");

  function diamondStorage() internal pure returns (AppStorage storage ds) {
    bytes32 position = DIAMOND_APP_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }
}
