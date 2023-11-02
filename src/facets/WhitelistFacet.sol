// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Whitelist } from "../shared/Structs.sol";
import { LibWhitelist } from "../libs/LibWhitelist.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { ReentrancyGuard } from "../shared/ReentrancyGuard.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

contract WhitelistFacet is AccessControl, ReentrancyGuard {
    event WhitelistUsersAdded(address[] _users);
    event WhitelistUsersRemoved(address[] _users);

    /**
     * @dev Adds addresses to a specific whitelist.
     * @param _users The addresses to be added to the whitelist.
     */
    function addAddressesToWhitelist(address[] calldata _users) external isDiamondAdmin() {
        require(_users.length > 0, "WhitelistFacet: _users must contain more than 0 address");

        LibWhitelist._addAddressesToWhitelist(_users);

        emit WhitelistUsersAdded(_users);
    }

    /**
     * @dev Removes addresses from a specific whitelist.
     * @param _users The addresses to be removed from the whitelist.
     */
    function removeAddressesFromWhitelist(address[] calldata _users) external isDiamondAdmin() {
        require(_users.length > 0, "WhitelistFacet: _users must contain more than 0 address");

        LibWhitelist._removeAddressesFromWhitelist(_users);

        emit WhitelistUsersRemoved(_users);
    }

    // 0 is non whitelisted, else return position in whitelist
    /**
     * @dev Checks if an address is whitelisted.
     * @param _user The address to check.
     * @return position uint256 Position of the address in the whitelist, 0 if not whitelisted.
     */
    function isWhitelisted(address _user) external view returns (uint256 position) {
        position = LibWhitelist.isWhitelisted(_user);
    }

    /**
     * @dev Retrieves information about a specific whitelist.
     * @return whitelist The information about the whitelist.
     */
    function getWhitelistInfos() external view returns (Whitelist memory) {
        return LibAppStorage.diamondStorage().whitelist;
    }
}