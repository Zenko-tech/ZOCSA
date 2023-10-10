// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { IERC721 } from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import { IERC721Metadata } from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { IERC721Facet } from "../interfaces/IERC721Facet.sol";
import { MetaContext } from "../shared/MetaContext.sol";
import { ERC721Infos } from "../shared/Structs.sol";

/**
 * @dev Facade implementation of ERC721 token.
 *
 * Our Diamond can deploy multiple such tokens, all backed by the same implementation within the Diamond.
 */
contract ERC721 is IERC721, IERC721Metadata, MetaContext {
  /**
   * @dev The parent Diamond that implements the business logic.
   */
  IERC721Facet private _parent;

  /**
   * @dev Constructor.
   *
   * @param parent The parent Diamond that implements the business logic.
   */
  constructor(IERC721Facet parent) {
    _parent = parent;
  }

  /*
    IERC721Metadata interface
  */
  function name() public view override returns (string memory) {
    return _parent.erc721Name(address(this));
  }

  function symbol() public view override returns (string memory) {
    return _parent.erc721Symbol(address(this));
  }


  /*
    IERC721 interface
  */
  function description() public view returns (string memory) {
    return _parent.erc721Description(address(this));
  }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance) {
        return _parent.erc721BalanceOf(address(this), owner);
    }

    /**
     * @dev Returns the avalaible reward amount in ``owner``'s account.
     */
    function rewardBalanceOf(address owner) external view returns (uint256 balance) {
        return _parent.erc721RewardBalanceOf(address(this), owner);
    }

    function rewardToken() external view returns (address) {
        return _parent.erc721RewardToken(address(this));
    }
    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner) {
        return _parent.erc721OwnerOf(address(this), tokenId);
    }

function tokenURI(uint256 tokenId) external view returns (string memory) {
  return _parent.erc721TokenURI(address(this), tokenId);
}

  function totalSupply() external view returns (uint256) {
    return _parent.erc721TotalSupply(address(this));
  }

  function maxSupply() external view returns (uint256) {
    return _parent.erc721MaxSupply(address(this));
  }
    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator) {
        return _parent.erc721GetApproved(address(this), tokenId);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _parent.erc721IsApprovedForAll(address(this), owner, operator);
    }

    function getCollectionAvailableDividends() external view returns (uint256 amount) {
      return _parent.erc721GetAvailableDividends(address(this));
    }

  /**
    * @dev Returns specific nft contracts infos.
    */
  function erc721GetCollectionInfos() external view returns (ERC721Infos memory)
  {
      return _parent.erc721GetCollectionInfos(address(this));
  }

    // #############################################################################################
    // *		Write Functions
    // #############################################################################################

    // only admin can now mint nft to ensure regulation restriction
    // function mint(address to, uint256 amount) external {
    //     _parent.erc721Mint(address(this), msg.sender, to, amount);
    // }
    
    function withdrawUserReward(address to, uint256 amount) external {
        _parent.erc721WithdrawUserEarnings(address(this), msg.sender, to, amount);
    }
    
    // /**
    //  * @dev Safely transfers `tokenId` token from `from` to `to`.
    //  *
    //  * Requirements:
    //  *
    //  * - `from` cannot be the zero address.
    //  * - `to` cannot be the zero address.
    //  * - `tokenId` token must exist and be owned by `from`.
    //  * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
    //  * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    //  *
    //  * Emits a {Transfer} event.
    //  */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {
        _parent.erc721SafeTransferFromPayload(address(this), from, to, tokenId, data);

    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        _parent.erc721SafeTransferFrom(address(this), from, to, tokenId);
    }

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external {
        _parent.erc721TransferFrom(address(this), from, to, tokenId);
    }

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external {
        _parent.erc721Approve(address(this), to, tokenId);
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external {
        _parent.erc721SetApprovalForAll(address(this), operator, approved);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {return true;}
}
