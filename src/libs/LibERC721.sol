// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ERC721Token, ERC721Checkpoint, ERC721Infos } from "../shared/Structs.sol";
import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { IERC721Receiver } from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import { LibString } from "./LibString.sol";

error ERC721NotEnoughFunds(address from);
error ERC721NotEnoughUserRewardBalance(address sender);
error ERC721NotEnoughFundsForReward(address from);
error ERC721CannotTransferUserReward(address from, address to);

library LibERC721 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event ERC721Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event ERC721UserRewardWithdraw(address indexed erc721Token, address  erc20Token, address indexed from, address indexed to, uint256 amount);
    event ERC721NewReward(address indexed erc721Token, uint256 amount);

    function tokenURI(address token, uint256 tokenID) internal view returns (string memory) {
      _requireMinted(token, tokenID); 
      ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
      string memory _tokenURI = t.tokenURIs[tokenID];
      string memory _base = t.baseUri;

      if (bytes(_base).length == 0) {
          return _tokenURI;
      } else if (bytes(_tokenURI).length > 0) {
          return string(abi.encodePacked(_base, _tokenURI));
      }

      return "";
    }

    function mint(address token, address to) internal {
        require(to != address(0), "ERC721: Cannot transfer to 0 address");
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        require(t.id < t.maxSupply, "ERC721: Cannot mint new Nft, max supply reached");
        _onAssetCountChange(token, to);
        
        // OCPE Price is now paid on web interface, admin minted to ensure regulation restriction
        // bool success = IERC20(t.rewardToken).transferFrom(from, LibAppStorage.diamondStorage().treasury, t.tokenPrice);
        // if (success == false) { 
        //     revert ERC721NotEnoughFunds(from);
        // }

        t.id += 1;
        uint256 tokenId = t.id;
        t.erc721Balances[to] += 1;
        t.owners[tokenId] = to;
        t.tokenURIs[tokenId] = LibString.toString(t.id); // Replace with specific individual URI
        
        require(
            _checkOnERC721Received(LibAppStorage.diamondStorage().adminMinter, address(0), to, tokenId, ""),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        emit ERC721Transfer(address(0), to, tokenId);
    }

       // admin send funds to this nft collection to dispatch user reward according to their number of nft hold
    function dispatchProjectReward(address token, address from, uint256 amount) internal returns (bool) {
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        uint256 totalNFTs = t.id;
        uint256 maxSupply = t.maxSupply;
        // // token id start at 1
        require(totalNFTs > 0, "No NFTs exist");

        if(totalNFTs < maxSupply)
        {
            _depositRewardNoRemainder(token, from, amount, totalNFTs, maxSupply);
        }
        else if (totalNFTs == maxSupply)
        {
            _depositRewardWithRemainder(token, from, amount, totalNFTs, maxSupply);
        }
        return true;
    }

    // Without remainder saving (leftoverReward)
    function _depositRewardNoRemainder(address token, address from, uint256 amount, uint256 totalNFTs, uint256 maxSupply) internal {
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        // uint256 requiredAmount = amount * totalNFTs / maxSupply;
        // uint256 rewardPerToken = requiredAmount / totalNFTs;
        // t.globalCheckpoint = ERC721Checkpoint({
        //     timestamp: block.timestamp,
        //     rewardPerToken: t.globalCheckpoint.rewardPerToken + rewardPerToken
        // });

        // require(IERC20(t.rewardToken).transferFrom(from, address(this), requiredAmount), "Transfer failed");
        // emit ERC721NewReward(token, requiredAmount);

         uint256 adjustedAmount = (amount / maxSupply) * totalNFTs;
        // The deposited amount is saved in the contract's balance
        t.checkpoints.push(ERC721Checkpoint({
            timestamp: block.timestamp,
            totalAmount: amount,
            depositedAmount: adjustedAmount,
            rewardPerToken: amount / maxSupply,
            totalSupplyAtTime: totalNFTs
        }));
        t.dividends[address(this)] += adjustedAmount;
        require(IERC20(t.rewardToken).transferFrom(from, address(this), adjustedAmount), "Transfer failed");
        // t.actualCheckpointsIndex++;
        emit ERC721NewReward(token, adjustedAmount);
    }

    // add leftover from previous reward to this dispatch
    function _depositRewardWithRemainder(address token, address from, uint256 amount, uint256 totalNFTs, uint256 maxSupply) internal {
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        // uint256 totalAmount = amount + t.leftoverReward;
        // uint256 rewardPerToken = totalAmount / totalNFTs;
        // t.leftoverReward = totalAmount % totalNFTs;

        // t.globalCheckpoint = ERC721Checkpoint({
        //     timestamp: block.timestamp,
        //     rewardPerToken: t.globalCheckpoint.rewardPerToken + rewardPerToken
        // });

        // require(IERC20(t.rewardToken).transferFrom(from, address(this), amount), "Transfer failed");
        // emit ERC721NewReward(token, amount);

        uint256 adjustedAmount = amount + t.leftoverReward;
        t.leftoverReward = adjustedAmount % maxSupply;
        // The deposited amount is saved in the contract's balance
        t.checkpoints.push(ERC721Checkpoint({
            timestamp: block.timestamp,
            totalAmount: amount,
            depositedAmount: amount,
            rewardPerToken: adjustedAmount / maxSupply,
            totalSupplyAtTime: totalNFTs
        }));
        t.dividends[address(this)] += amount;
        require(IERC20(t.rewardToken).transferFrom(from, address(this), amount), "Transfer failed");
        // t.actualCheckpointsIndex++;
        emit ERC721NewReward(token, amount);
    }
    function withdrawUserReward(address token, address from, address to, uint256 amount) internal returns (bool) {
        // require(to != address(0), "ERC721: Cannot transfer ERC20 to 0 address");
        // ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        // _updateUserRewards(token, from);
        // uint256 reward = t.userRewardsBalance[from];
        // require(reward > 0, "No rewards to claim");
        // t.userRewardsBalance[from] = 0;
        // require(IERC20(t.rewardToken).transfer(to, reward), "Transfer failed");
        // emit ERC721UserRewardWithdraw(token, t.rewardToken, from, to, amount);
        // return true;

        require(to != address(0), "ERC721: Cannot transfer ERC20 to 0 address");
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        _calculateDividend(token, from);
        require(t.dividends[from] >= amount, "No enough dividends to withdraw");
        //withdraw from potential DeFi integration would take place here
        // ...
        
        t.dividends[from] -= amount;
        t.dividends[address(this)] -= amount;

        require(IERC20(t.rewardToken).transfer(to, amount), "Transfer failed");
        emit ERC721UserRewardWithdraw(token, t.rewardToken, from, to, amount);
        return true;
    }

    function _calculateDividend(address token, address user) internal {
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        uint256 totalDividend = 0;
        for (uint256 i = t.lastClaimedCheckpointIndex[user]; i < t.checkpoints.length; i++) {
            ERC721Checkpoint memory checkpoint = t.checkpoints[i];
            uint256 userDividend = t.erc721Balances[user] * checkpoint.rewardPerToken;
            totalDividend += userDividend;
            
            t.lastClaimedCheckpointIndex[user] = i + 1;
        }
        // if any user diff supply minted between checkpoint, add temp balance and reset
        if (t.dividendsTempBalance[user] > 0)
        {
            totalDividend += t.dividendsTempBalance[user];
            t.dividendsTempBalance[user] = 0;
        }
        if (totalDividend > 0)
        {
            t.dividends[user] += totalDividend;
        }
   }

    function _onAssetCountChange(address token, address user) internal {
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        if(t.erc721Balances[user] > 0)
        {
            uint256 totalDividend = 0;
            for (uint256 i = t.lastClaimedCheckpointIndex[user]; i < t.checkpoints.length; i++) {
                ERC721Checkpoint memory checkpoint = t.checkpoints[i];
                uint256 userDividend = t.erc721Balances[user] * checkpoint.rewardPerToken;
                totalDividend += userDividend;
                
                t.lastClaimedCheckpointIndex[user] = i + 1;
            }   
            if (totalDividend > 0)
            {
                t.dividendsTempBalance[user] += totalDividend;
            }
            if (t.dividends[user] > 0)
            {
                t.dividendsTempBalance[user] += t.dividends[user];
                t.dividends[user] = 0;
            }
        }
        // user has no shares at this checkpoint
        else 
        {
            t.lastClaimedCheckpointIndex[user] = t.checkpoints.length;
        }
    }
    function consultUserRewards(address token, address user) internal view returns (uint256 res){
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        uint256 totalDividend = 0;
        for (uint256 i = t.lastClaimedCheckpointIndex[user]; i < t.checkpoints.length; i++) {
            ERC721Checkpoint memory checkpoint = t.checkpoints[i];
            uint256 userDividend = t.erc721Balances[user] * checkpoint.rewardPerToken;
            totalDividend += userDividend;
        }
        totalDividend += t.dividendsTempBalance[user];
        totalDividend += t.dividends[user];
        return totalDividend;
    }

    function getAllCollectionsInfos() internal view returns (ERC721Infos[] memory) {
        address[] memory collections = LibAppStorage.diamondStorage().erc721Collections;
        uint256 length = collections.length;
        ERC721Infos[] memory data = new ERC721Infos[](length);

        for (uint256 i = 0; i < length; i++) {
            ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[collections[i]];

            data[i] = ERC721Infos(
                collections[i],
                t.name,
                t.symbol,
                t.description,
                t.id,
                t.maxSupply,
                t.collectionRewardRate,
                t.individualShare,
                t.tokenPrice,
                t.rewardToken,
                t.checkpoints.length,
                t.leftoverReward
            );
        }

        return data;
    }

    function getCollectionInfos(address collectionAddress) internal view returns (ERC721Infos memory) {
        ERC721Infos memory data;
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[collectionAddress];

        data = ERC721Infos(
            collectionAddress,
            t.name,
            t.symbol,
            t.description,
            t.id,
            t.maxSupply,
            t.collectionRewardRate,
            t.individualShare,
            t.tokenPrice,
            t.rewardToken,
            t.checkpoints.length,
            t.leftoverReward
        );

        return data;
    }

    // function _onNFTTransfer(address token, address from, address to, uint256 tokenId) internal {
    //     // This function can be called after an NFT transfer to update rewards for both the sender and receiver
    //     if(from != address(0))
    //     {
    //         _onAssetCountChange(token, from);
    //     }
    //     if (to != address(0))
    //     {
    //         _onAssetCountChange(token, to);
    //     }
    // }

    // /!\ WIP commented
    function transfer(address token, address from, address to, uint256 tokenID) internal returns (bool){
    //   require(to != address(0), "ERC721: Cannot transfer to 0 address");
    //   _requireMinted(tokenID);
    //   _requireOwner(from, tokenID);
    //   /* _requireAuth(from, tokenID); */ // commented

    //  _onNFTTransfer(token, from, to, tokenId);

    //   ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        // _onNFTTransfer();
    //   delete t.tokenApprovals[tokenID];
    //   t.owners[tokenID] = to;
    //   t.balances[msg.sender] -= 1;
    //   t.balances[to] += 1;

    //   withdrawUserReward(token, from, from, t.erc20Balances[from]); // withdraw staked funds to owner before transfer
    //   emit Transfer(msg.sender, to, tokenID);
      return true;
    }

    function _setIndividualShare(address token) internal {
        // helper function that might be called in constructor aswell
        ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
        uint256 _newShare = t.collectionRewardRate / t.maxSupply;
        t.individualShare = _newShare;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address msgSender,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msgSender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _requireMinted(address token, uint256 tokenId) internal view {
      require(_exists(token, tokenId), "ERC721: invalid token ID");
    }
    function _exists(address token,uint256 tokenId) internal view returns (bool) {
      return _owner(token, tokenId) != address(0);
    }
    function _owner(address token, uint256 tokenID) internal view returns (address){
      ERC721Token storage t = LibAppStorage.diamondStorage().erc721s[token];
      return t.owners[tokenID];
    }
}
