// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// import { ERC20 } from "../facades/ERC20.sol";
import { ERC721Token } from "../shared/Structs.sol";
import { ERC721 } from "../facades/ERC721.sol";
import { LibERC721 } from "../libs/LibERC721.sol";
import { IAdminFacet } from "../interfaces/IAdminFacet.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { AppStorage, LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

error ERC721InvalidInput();

contract AdminFacet is IAdminFacet, AccessControl {  

  function setTreasuryAddress(address treasury) external isAdmin {
    require (treasury != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.treasury = treasury;
  }

  function setAdminMinterAddress(address newMinter) external isAdmin {
    require (newMinter != address(0), "Address 0");
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.adminMinter = newMinter;
  }

  function erc721Mint(address token, address to, uint256 count) external isAdminMinter {
    for (uint256 i = 0; i < count; i++)
    {
      LibERC721.mint(token, to);
    }
  }

  function erc721UpdateProjectDescription(address token, string memory newDescription) external isAdmin {
    if (LibString.len(newDescription) == 0) {
      revert ERC721InvalidInput();
    }
    ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
    t.description = newDescription;
  }
  
  function erc721UpdateCollectionBaseUri(address token, string memory newBaseUri) external isAdmin {
    if (LibString.len(newBaseUri) == 0) {
      revert ERC721InvalidInput();
    }
    ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
    t.baseUri = newBaseUri;
  }


  function erc721DispatchUserReward(address token, uint256 amount) external isAdmin {
    if (amount == 0) {
      revert ERC721InvalidInput();
    }
    LibERC721.dispatchProjectReward(token, msg.sender, amount);
  }

  // function erc721UpdateProjectRewardRate(address token, uint256 newRate) external isAdmin {
  //   if (newRate == 0) {
  //     revert ERC721InvalidInput();
  //   }
  //   ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
  //   t.collectionRewardRate = newRate;
  //   LibERC721._setIndividualShare(token);
  // }
  

}