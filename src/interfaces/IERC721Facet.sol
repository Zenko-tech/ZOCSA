// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;
import { ERC721Infos } from "../shared/Structs.sol";

/**
 * @dev ERC721 diamond facet interface.
 */
interface IERC721Facet {

	// #############################################################################################
	// *		Events
	// #############################################################################################

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event ERC721Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ERC721ApprovalForAll(address indexed owner, address indexed operator, bool approved);

	// #############################################################################################
	// *		View Functions
	// #############################################################################################


  /**
   * @dev Deploy new token.
   *
   * @param name The name of the token.
   * @param symbol The symbol of the token.
   */
  function erc721DeployToken(
    string memory name,
    string memory symbol,
    string memory description,
    string memory baseUri,
    uint256 maxSupply,
    uint256 collectionRewardRate,
    uint256 tokenPrice,
    address rewardToken
  ) external returns(address);

  /**
    * @dev Returns all deployed nft contracts infos.
    */
  function erc721GetAllCollectionsInfos() external view returns (ERC721Infos[] memory);

  /**
    * @dev Returns specific nft contracts infos.
    */
  function erc721GetCollectionInfos(address token) external view returns (ERC721Infos memory);
  
  /**
   * @dev Returns the name of the token.
   *
   * @param token The token address.
   */
  function erc721Name(address token) external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
   *
   * @param token The token address.
   */
  function erc721Symbol(address token) external view returns (string memory);

  /**
   * @dev Returns the project description of the token.
   *
   * @param token The token address.
   */
  function erc721Description(address token) external view returns (string memory);

  function erc721TokenURI(address token, uint256 tokenId) external view returns (string memory);
  /**
   * @dev Get this collection project reward rate.
   *
   * @param token The token address.
   */
  function erc721CollectionRewardRate(address token) external view returns (uint256);

  /**
   * @dev Get the total supply.
   *
   * @param token The token address.
   */
  function erc721TotalSupply(address token) external view returns (uint256);

  /**
   * @dev Get the max supply.
   *
   * @param token The token address.
   */
  function erc721MaxSupply(address token) external view returns (uint256);

  /**
   * @dev Returns the number of erc721 tokens in owner's account.
   *
   * @param token The token address.
   * @param owner The owner address.
   */
  function erc721BalanceOf(address token, address owner) external view returns (uint256);

  /**
   * @dev Returns the reward balance for this collection by this user (all nfts earnings) 
   *
   * @param token The token address.
   * @param owner The owner address.
   */
  function erc721RewardBalanceOf(address token, address owner) external view returns (uint256);

  /**
   * @dev Returns the address of the reward token paid by the protocol
   *
   * @param token The token address.
   */
  function erc721RewardToken(address token) external view returns (address);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
	* @param token The token address.
	* @param tokenId The token Id.
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function erc721OwnerOf(address token, uint256 tokenId) external view returns (address owner);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
	 * @param token The token address.
	 * @param owner The owner address.
	 * @param operator The potential allowed operator address.
     * See {setApprovalForAll}
     */
    function erc721IsApprovedForAll(address token, address owner, address operator) external view returns (bool);

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
	 * @param token The token address.
	 * @param tokenId The tokenId.
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function erc721GetApproved(address token, uint256 tokenId) external view returns (address operator);


    function erc721GetAvailableDividends(address token) external view returns (uint256 amount);

    function erc721GetOCSAPrice(address token) external view returns (uint256 amount);

	// #############################################################################################
	// *		Write Functions
	// #############################################################################################

  /**
   * @dev Mint new Nfts.
   *
* @param token The token address.
   * @param from The sender address.
   @param to The recipient address.
   * @param count The total nft to mint.
   */
	// function erc721Mint(address token, address from, address to, uint256 count) external;

  /**
   * @dev Withdraw user earned shares.
   *
	* @param token The token address.
   * @param from The sender address.
   @param to The recipient address.
   * @param amount The total funds to withdraw (in wei).
   */
	function erc721WithdrawUserEarnings(address token, address from, address to, uint256 amount) external;

	// /**
  //    * @dev Safely transfers `tokenId` token from `from` to `to`.
  //    *
  //    * Requirements:
  //    *
  //    * - `from` cannot be the zero address.
  //    * - `to` cannot be the zero address.
  //    * - `tokenId` token must exist and be owned by `from`.
  //    * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
  //    * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
  //    *
  //    * Emits a {Transfer} event.
  //    */
    function erc721SafeTransferFromPayload(
		address token,
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function erc721SafeTransferFrom(
		address token,
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function erc721TransferFrom(
		address token,
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function erc721Approve(address token, address to, uint256 tokenId) external;

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
    function erc721SetApprovalForAll(address token, address operator, bool _approved) external;
}
