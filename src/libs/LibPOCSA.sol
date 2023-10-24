// // SPDX-License-Identifier: MIT
// pragma solidity >=0.8.21;

// import { POCSAToken, POCSACheckpoint, POCSAInfos } from "../shared/POCSAStructs.sol";
// import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";
// import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// error POCSANotEnoughBalance(address sender);

// library POCSA {
//   /**
//    * @dev Emitted when a token is minted.
//    */
//   event POCSAMinted(address token, address to, uint256 amount);
//   /**
//    * @dev Emitted when a token is burned.
//    */
//   event POCSABurned(address token, address from, uint256 amount);
//   /**
//    * @dev Emitted when a token is transferred for sale to marketplace.
//    */
//   event POCSATransferredToMarketPlace(address token, address from, address marketPlace, uint256 value);
//     /**
//    * @dev Emitted when a token is sold from marketplace and send to buyer.
//    */
//   event POCSABuyFromMarketPlace(address token, address marketPlace, address from, address to, uint256 value);
//   /**
//    * @dev Emitted when a token is approved for a spender.
//    */
//   event POCSAApproval(address token, address owner, address spender, uint256 value);
//     /**
//    * @dev Emitted when a user claim his rewards.
//    */
//   event POCSAUserRewardWithdraw(address indexed POCSAToken, address  erc20Token, address indexed from, address indexed to, uint256 amount);
//     /**
//    * @dev Emitted when a new reward checkpoint is created.
//    */
//   event POCSANewReward(address indexed POCSAToken, uint256 amount);
  
//   /*
//     ERC20 implementation
//   */
  
//   /**
//     * @dev Mint a token.
//     *
//     * @param token The token to mint.
//     * @param to The address to mint the token to.
//     * @param amount The amount to mint.
//     */
//   function mint(address token, address to, uint256 amount) internal {
//     require(to != address(0), "POCSA: Cannot transfer to 0 address");
//     POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//     require((amount + t.totalSupply) <= t.maxSupply, "POCSA: Cannot mint new OCSA, max supply reached");
    
//     _onAssetCountChange(token, to);

//     t.totalSupply += amount;
//     t.balances[to] += amount;

//     emit POCSAMinted(token, to, amount);
//   }  

//   /**
//     * @dev Approve tokens for a delegate.
//     * @param token The address of the token.
//     * @param account The address of the token holder.
//     * @param spender The address of the spender.
//     * @param amount The number of tokens to approve.
//     */
//   function approve(address token, address account, address spender, uint256 amount) external {
//     revert("Not Implemented Yet");

//     // LibAppStorage.diamondStorage().pOcsas[token].allowances[account][spender] = amount;
//     // emit POCSAApproval(token, account, spender, amount);
//   }

//   /**
//     * @dev Transfer a token.
//     *
//     * @param token The token to transfer.
//     * @param from The address to transfer the token from.
//     * @param to The address to transfer the token to.
//     * @param amount The amount to transfer.
//     */
//   function transfer(address token, address from, address to, uint256 amount) internal {
//     revert("Not Implemented Yet");
//     // POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];

//     // if (amount > t.balances[from]) {
//     //   revert POCSANotEnoughBalance(from);
//     // }
//     // _onOCSATransfer(token, from, to);
//     // t.balances[from] -= amount;
//     // t.balances[to] += amount;

//     // emit POCSATransferredToMarketPlace(token, from, to, amount);
//   }

//   /**
//     * @dev Burn a token.
//     *
//     * @param token The token to burn.
//     * @param from The address to burn the token from.
//     * @param amount The amount to burn.
//     */
//   function burn(address token, address from, uint256 amount) internal {
//     revert("Not Implemented Yet");

//     // POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//     // if (t.balances[from] < amount) {
//     //   revert POCSANotEnoughBalance(from);
//     // }
//     // _onAssetCountChange(token, from);
//     // t.totalSupply -= amount;
//     // t.balances[from] -= amount;

//     // emit POCSABurned(token, from, amount);
//   }  

//   /*
//     OCSA implementation
//   */

//   /**
//     * @dev Withdraw user rewards.
//     * @param token The address of the POCSA token.
//     * @param from Address from which to withdraw.
//     * @param to Address to which to transfer rewards.
//     * @param amount Number of rewards to withdraw.
//     * @return bool Returns true if successful.
//     */
//   function withdrawUserReward(address token, address from, address to, uint256 amount) internal returns (bool) {
//       require(to != address(0), "POCSA: Cannot transfer ERC20 to 0 address");
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//       _calculateDividend(token, from);
//       require(t.dividends[from] >= amount, "POCSA: No enough dividends to withdraw");
//       //withdraw from potential DeFi integration would take place here
//       // ...
      
//       t.dividends[from] -= amount;
//       t.dividends[address(this)] -= amount;

//       require(IERC20(t.rewardToken).transfer(to, amount), "POCSA: Reward Transfer failed");
//       emit POCSAUserRewardWithdraw(token, t.rewardToken, from, to, amount);
//       return true;
//   }

//     /**
//     * @dev Dispatch rewards for the project.
//     * @dev admin send funds to this OCSA collection to dispatch user reward according to their number of ocsa hold
//     * @param token The address of the POCSA token.
//     * @param from Address from which rewards are coming.
//     * @param amount Amount of rewards to dispatch.
//     * @return bool Returns true if successful.
//     */
//   function dispatchProjectReward(address token, address from, uint256 amount) internal returns (bool) {
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//       uint256 totalSupply = t.totalSupply;
//       uint256 maxSupply = t.maxSupply;
//       require(totalSupply > 0, "POCSA: No OCSA exist");

//       if(totalSupply < maxSupply)
//       {
//           _depositRewardNoRemainder(token, from, amount, totalSupply, maxSupply);
//       }
//       else if (totalSupply == maxSupply)
//       {
//           _depositRewardWithRemainder(token, from, amount, totalSupply, maxSupply);
//       }
//       return true;
//   }

//   /**
//    * @notice Get the total rewards for a user in a POCSA collection
//    * @dev Function to consult the total awailable rewards for a user
//    * @param token The address of the POCSA token
//    * @param user The address of the user
//    * @return res Returns the total amount of rewards for the user
//    */

//   function consultUserRewards(address token, address user) internal view returns (uint256 res){
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//       uint256 totalDividend = 0;
//       for (uint256 i = t.lastClaimedCheckpointIndex[user]; i < t.checkpoints.length; i++) {
//           POCSACheckpoint memory checkpoint = t.checkpoints[i];
//           uint256 userDividend = t.balances[user] * checkpoint.rewardPerToken;
//           totalDividend += userDividend;
//       }
//       totalDividend += t.dividendsTempBalance[user];
//       totalDividend += t.dividends[user];
//       return totalDividend;
//   }

//   /**
//     * @dev Get information about all POCSA collections.
//     * @return POCSAInfos[] Array containing information about each POCSA collection.
//     */
//   function getAllCollectionsInfos() internal view returns (POCSAInfos[] memory) {
//       address[] memory collections = LibAppStorage.diamondStorage().pOcsaCollections;
//       uint256 length = collections.length;
//       POCSAInfos[] memory data = new POCSAInfos[](length);

//       for (uint256 i = 0; i < length; i++) {
//           POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[collections[i]];

//           data[i] = POCSAInfos(
//               collections[i],
//               t.name,
//               t.symbol,
//               t.description,
//               t.totalSupply,
//               t.maxSupply,
//               t.collectionRewardRate,
//               t.individualShare,
//               t.tokenPrice,
//               t.rewardToken,
//               t.checkpoints.length,
//               t.leftoverReward
//           );
//       }

//       return data;
//   }

//   /**
//     * @dev Get information about a specific POCSA collection.
//     * @param collectionAddress The address of the POCSA collection.
//     * @return POCSAInfos Information about the specified POCSA collection.
//     */
//   function getCollectionInfos(address collectionAddress) internal view returns (POCSAInfos memory) {
//       POCSAInfos memory data;
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[collectionAddress];

//       data = POCSAInfos(
//           collectionAddress,
//           t.name,
//           t.symbol,
//           t.description,
//           t.totalSupply,
//           t.maxSupply,
//           t.collectionRewardRate,
//           t.individualShare,
//           t.tokenPrice,
//           t.rewardToken,
//           t.checkpoints.length,
//           t.leftoverReward
//       );

//       return data;
//   }

//   /**
//     * @dev Internal function to set individual share.
//     * @dev Reward Rate / Max Supply.
//     * @param token The address of the POCSA token.
//     */
//   function _setIndividualShare(address token) internal {
//       // helper function that might be called in constructor aswell
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//       uint256 _newShare = t.collectionRewardRate / t.maxSupply;
//       t.individualShare = _newShare;
//   }

//   /**
//   * @dev Deposit rewards without accounting for remainder (leftover).
//   * @param token The address of the POCSA token.
//   * @param from The source address depositing the rewards.
//   * @param amount The amount to deposit as rewards.
//   * @param totalSupply The current total supply of the POCSA token.
//   * @param maxSupply The maximum possible supply of the POCSA token.
//   */
//   function _depositRewardNoRemainder(address token, address from, uint256 amount, uint256 totalSupply, uint256 maxSupply) internal {
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//         uint256 adjustedAmount = (amount / maxSupply) * totalSupply;

//       // The deposited amount is saved in the contract's balance
//       t.checkpoints.push(POCSACheckpoint({
//           timestamp: block.timestamp,
//           totalAmount: amount,
//           depositedAmount: adjustedAmount,
//           rewardPerToken: amount / maxSupply,
//           totalSupplyAtTime: totalSupply
//       }));
//       t.dividends[address(this)] += adjustedAmount;
//       require(IERC20(t.rewardToken).transferFrom(from, address(this), adjustedAmount), "POCSA: Reward Deposit Transfer failed");
//       emit POCSANewReward(token, adjustedAmount);
//   }

//   /**
//     * @dev Deposit rewards and include any remainder from previous deposits.
//     * @param token The address of the POCSA token.
//     * @param from The source address depositing the rewards.
//     * @param amount The amount to deposit as rewards.
//     * @param totalSupply The current total supply of the POCSA token.
//     * @param maxSupply The maximum possible supply of the POCSA token.
//     */
//   function _depositRewardWithRemainder(address token, address from, uint256 amount, uint256 totalSupply, uint256 maxSupply) internal {
//       POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//       uint256 adjustedAmount = amount + t.leftoverReward;

//       t.leftoverReward = adjustedAmount % maxSupply;
//       // The deposited amount is saved in the contract's balance
//       t.checkpoints.push(POCSACheckpoint({
//           timestamp: block.timestamp,
//           totalAmount: amount,
//           depositedAmount: amount,
//           rewardPerToken: adjustedAmount / maxSupply,
//           totalSupplyAtTime: totalSupply
//       }));
//       t.dividends[address(this)] += amount;
//       require(IERC20(t.rewardToken).transferFrom(from, address(this), amount), "POCSA: Reward Deposit Transfer failed");
//       emit POCSANewReward(token, amount);
//   }

//   /**
//     * @dev Calculate the dividend for a user up to the current checkpoint.
//     * @param token The address of the POCSA token.
//     * @param user The address of the user.
//     */
//   function _calculateDividend(address token, address user) internal {
//     POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//     uint256 totalDividend = 0;
//     for (uint256 i = t.lastClaimedCheckpointIndex[user]; i < t.checkpoints.length; i++) {
//         POCSACheckpoint memory checkpoint = t.checkpoints[i];
//         uint256 userDividend = t.balances[user] * checkpoint.rewardPerToken;
//         totalDividend += userDividend;
        
//         t.lastClaimedCheckpointIndex[user] = i + 1;
//     }
//     // if any user diff supply minted between checkpoint, add temp balance and reset
//     if (t.dividendsTempBalance[user] > 0)
//     {
//         totalDividend += t.dividendsTempBalance[user];
//         t.dividendsTempBalance[user] = 0;
//     }
//     if (totalDividend > 0)
//     {
//         t.dividends[user] += totalDividend;
//     }
//   }

//   /**
//     * @dev Handle changes in asset count for a user.
//     * @param token The address of the POCSA token.
//     * @param user The address of the user whose asset count has changed.
//     */
//   function _onAssetCountChange(address token, address user) internal {
//     POCSAToken storage t = LibAppStorage.diamondStorage().pOcsas[token];
//     if (user != LibAppStorage.diamondStorage().OCSAMarketplace && user != address(this))
//     {
//       if(t.balances[user] > 0)
//       {
//         uint256 totalDividend = 0;
//         for (uint256 i = t.lastClaimedCheckpointIndex[user]; i < t.checkpoints.length; i++) {
//             POCSACheckpoint memory checkpoint = t.checkpoints[i];
//             uint256 userDividend = t.balances[user] * checkpoint.rewardPerToken;
//             totalDividend += userDividend;
            
//             t.lastClaimedCheckpointIndex[user] = i + 1;
//         }   
//         if (totalDividend > 0)
//         {
//             t.dividendsTempBalance[user] += totalDividend;
//         }
//         if (t.dividends[user] > 0)
//         {
//             t.dividendsTempBalance[user] += t.dividends[user];
//             t.dividends[user] = 0;
//         }
//       }
//       // user has no shares at this checkpoint
//       else 
//       {
//           t.lastClaimedCheckpointIndex[user] = t.checkpoints.length;
//       }
//     }
//   }

//   /**
//     * @dev Handle changes in asset count between two user.
//     * @param token The address of the POCSA token.
//     * @param from The address of the user whose asset count has changed.
//     * @param to The address of the user whose asset count has changed.
//     */
//   function _onOCSATransfer(address token, address from, address to) internal {
//       // This function can be called before an OCSA transfer to update rewards for both the sender and receiver
//       if(from != address(0) && from != address(this))
//       {
//           _onAssetCountChange(token, from);
//       }
//       if (to != address(0) && to != address(this))
//       {
//           _onAssetCountChange(token, to);
//       }
//   }
// }
