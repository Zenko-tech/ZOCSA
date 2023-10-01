// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ERC721Infos } from "../shared/Structs.sol";

/**
 * @dev ERC721 diamond facet interface.
 */
interface IAdminFacet {

	// #############################################################################################
	// *		Events
	// #############################################################################################

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    // event ERC721Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);


	// #############################################################################################
	// *		Write Functions
	// #############################################################################################
  
  function setTreasuryAddress(address treasury) external;
  
  function setAdminMinterAddress(address newMinter) external;


  function erc721Mint(address token, address to, uint256 count) external;
  

  function erc721UpdateProjectDescription(address token, string memory newDescription) external;
  
  function erc721UpdateCollectionBaseUri(address token, string memory newBaseUri) external;


  function erc721DispatchUserReward(address token, uint256 amount) external;

  // function erc721IncreaseMaxSupply(address token, uint256 supplyToAdd) external;
  // function erc721UpdateProjectRewardRate(address token, uint256 newRate) external;


}
