// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Whitelist } from "../shared/Structs.sol";
import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";

library LibWhitelist {

    /**
     * @dev Checks if a given address is whitelisted.
     * @param user The address to check.
     * @return uint256 The status of the address in the whitelist.
     */
    function isWhitelisted(address user) internal view returns (uint256) {
        return LibAppStorage.diamondStorage().isWhitelisted[user];
    }

    /**
     * @dev Adds an address to a specific whitelist.
     * @param _whitelistAddress The address to be added to the whitelist.
     */
    function _addAddressToWhitelist(address _whitelistAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isWhitelisted[_whitelistAddress] == 0) {
            Whitelist storage whitelist = s.whitelist;
            whitelist.addresses.push(_whitelistAddress);
            s.isWhitelisted[_whitelistAddress] = whitelist.addresses.length; // Index of the whitelist entry + 1
        }
    }

    /**
     * @dev Removes an address from a specific whitelist.
     * @param _whitelistAddress The address to be removed from the whitelist.
     */
    function _removeAddressFromWhitelist(address _whitelistAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isWhitelisted[_whitelistAddress] > 0) {
            Whitelist storage whitelist = s.whitelist;
            uint256 index = s.isWhitelisted[_whitelistAddress] - 1;
            uint256 lastIndex = whitelist.addresses.length - 1;
            // Replaces the element to be removed with the last element
            whitelist.addresses[index] = whitelist.addresses[lastIndex];
            // Store the last element in memory
            address lastElement = whitelist.addresses[lastIndex];
            // Remove the last element from storage
            whitelist.addresses.pop();
            // Update the index of the last element that was swapped. If this is the only element, updates to zero on the next line
            s.isWhitelisted[lastElement] = index + 1;
            // Update the index of the removed element
            s.isWhitelisted[_whitelistAddress] = 0;
        }
    }

    /**
     * @dev Adds multiple addresses to a specific whitelist.
     * @param _whitelistAddresses An array of addresses to be added to the whitelist.
     */
    function _addAddressesToWhitelist(address[] memory _whitelistAddresses) internal {
        for (uint256 i; i < _whitelistAddresses.length; i++) {
            _addAddressToWhitelist(_whitelistAddresses[i]);
        }
    }

    /**
     * @dev Removes multiple addresses from a specific whitelist.
     * @param _whitelistAddresses An array of addresses to be removed from the whitelist.
     */
    function _removeAddressesFromWhitelist(address[] memory _whitelistAddresses) internal {
        for (uint256 i; i < _whitelistAddresses.length; i++) {
            _removeAddressFromWhitelist(_whitelistAddresses[i]);
        }
    }
}