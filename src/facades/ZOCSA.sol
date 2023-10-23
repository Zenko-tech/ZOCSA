// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IZOCSAFacet } from "../interfaces/IZOCSAFacet.sol";
import { MetaContext } from "../shared/MetaContext.sol";
import { ZOCSAInfos } from "../shared/Structs.sol";

/**
 * @dev Facade implementation of ERC20 token.
 * 
 * Diamond can deploy multiple such tokens, all backed by the same implementation within the Diamond.
 */
contract ZOCSA is IERC20, IERC20Metadata, MetaContext {
  /**
   * @dev The parent Diamond that implements the business logic.
   */
  IZOCSAFacet private _parent;

  /**
   * @dev Constructor.
   *
   * @param parent The parent Diamond that implements the business logic.
   */
  constructor(IZOCSAFacet parent) {
    _parent = parent;
  }

  /*
    IERC20Metadata interface
  */

  /**
   * @notice Returns the name of the token.
   * @return Token name.
   */
  function name() public view override returns (string memory) {
    return _parent.ZOCSAName();
  }

  /**
   * @notice Returns the symbol of the token.
   * @return Token symbol.
   */
  function symbol() public view override returns (string memory) {
    return _parent.ZOCSASymbol();
  }  

  /**
   * @notice Returns the decimals of the token.
   * @return Token decimals.
   */
  function decimals() public view override returns (uint8) {
    return _parent.ZOCSADecimals();
  }

  /*
    IERC20 interface
    view functions
  */

  /**
   * @notice Returns the total supply of the token.
   * @return Total supply of tokens.
   */
  function totalSupply() public view override returns (uint256) {
    return _parent.ZOCSATotalSupply();
  }

  /**
   * @dev Returns the number of tokens (OCSA) in `owner`'s account.
   * @param account The address of the token owner.
   * @return balance The balance of tokens owned by `owner`.
   */
  function balanceOf(address account) public view override returns (uint256) {
    return _parent.ZOCSABalanceOf(account);
  }

  /**
   * @notice Returns the allowance of tokens from an owner to a spender.
   * @param owner Address of the owner.
   * @param spender Address of the spender.
   * @return Allowed amount.
   */
  function allowance(address owner, address spender) public view override returns (uint256) {
    return _parent.ZOCSAAllowance(owner, spender);
  }

  /*
    IERC20 interface
    write functions
  */

  /**
   * @notice Approves the spender to spend a certain amount of tokens.
   * @param spender The address to be approved.
   * @param amount The amount to approve.
   * @return True if operation is successful.
   */
  function approve(address spender, uint256 amount) public override returns (bool) {
    _parent.ZOCSAApprove(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @notice Transfers tokens from the caller to a recipient.
   * @param recipient The address of the recipient.
   * @param amount The amount to be transferred.
   * @return True if operation is successful.
   */
  function transfer(address recipient, uint256 amount) public override returns (bool) {
    address caller = _msgSender();
    _parent.ZOCSATransfer(caller, caller, recipient, amount);
    return true;
  }

  /**
   * @notice Transfers tokens from sender to recipient.
   * @param sender The address of the sender.
   * @param recipient The address of the recipient.
   * @param amount The amount to be transferred.
   * @return True if operation is successful.
   */
  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _parent.ZOCSATransfer(_msgSender(), sender, recipient, amount);
    return true;
  }

  /*
    ZOCSA Interface
    view functions
  */

    /**
   * @dev Returns the OCSA project description.
   * @return The project description as a string.
   */

  function description() public view returns (string memory) {
    return _parent.ZOCSADescription();
  }

  /**
    * @dev Returns the max mintable supply of this collection.
  */
  function maxSupply() external view returns (uint256) {
    return _parent.ZOCSAMaxSupply();
  }

/**
  * @dev Returns the available reward amount in `owner`'s account available to withdraw.
  * @param owner The address of the token owner.
  * @return balance The available reward balance of `owner`.
  */
  function rewardBalanceOf(address owner) external view returns (uint256 balance) {
    return _parent.ZOCSARewardBalanceOf(owner);
  }

/**
  * @dev Returns the address of the token used for paying rewards.
  * @return The address of the reward token.
  */
  function rewardToken() external view returns (address) {
    return _parent.ZOCSARewardToken();
  }

  /**
    * @dev Returns all the reward deposited on this collection available by users to withdraw.
    */
  function getCollectionAvailableDividends() external view returns (uint256 amount) {
    return _parent.ZOCSAGetAvailableDividends();
  }

  /**
   * @dev Returns specific NFT collection information.
   * @return Collection information as a struct.
   */
  function getCollectionInfos() external view returns (ZOCSAInfos memory)
  {
      return _parent.ZOCSAGetCollectionInfos();
  }

  /*
    ZOCSA Interface
    write functions
  */

  /**
  * @notice Withdraws reward earnings to a specified address.
  * @param to The address to receive the withdrawn rewards.
  * @param amount The amount of rewards to withdraw.
  */
  function withdrawUserReward(address to, uint256 amount) external {
      _parent.ZOCSAWithdrawUserEarnings(_msgSender(), to, amount);
  }
}
