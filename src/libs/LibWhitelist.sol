// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Whitelist } from "../shared/Structs.sol";
import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";

library LibWhitelist {

    /**
     * @dev Creates a new whitelist with the provided name and admin addresses.
     * @param _name The name of the whitelist.
     * @param _adminAddresses An array of admin addresses to be added to the whitelist.
     * @param _whitelistAddresses An array of addresses to be whitelisted initially.
     * @param _addZenkoWhiteList A flag indicating whether Zenko whitelist is to be added.
     * @return uint32 The ID of the newly created whitelist.
     */
    function createNewWhitelist(
        string memory _name, 
        address[] memory _adminAddresses, 
        address[] memory _whitelistAddresses,
        bool _addZenkoWhiteList
    ) internal returns(uint32) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint32 whitelistId = getNewWhitelistId();
        address[] memory addresses;
        Whitelist memory whitelist = Whitelist({name: _name, admins: _adminAddresses, addresses: addresses, addZenkoWhiteList: _addZenkoWhiteList});

        s.whitelists.push(whitelist);

        _addAddressesToWhitelist(whitelistId, _whitelistAddresses);

        _addAdminsToWhiteList(whitelistId, _adminAddresses);
        return (whitelistId);
    }

    /**
     * @dev Adds Zenko whitelist check for a partner ocsa to a given whitelist ID.
     * @param _whitelistId The ID of the whitelist to add Zenko whitelist.
     */
    function addZenkoWhitelistToPOCSA(uint32 _whitelistId) internal {
        Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
        whitelist.addZenkoWhiteList = true;
    }

    /**
     * @dev Generates a new whitelist ID.
     * @return whitelistId uint32 The new whitelist ID.
     */
    function getNewWhitelistId() internal view returns (uint32 whitelistId) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        whitelistId = uint32(s.whitelists.length + 1); //whitelistId 0 is reserved for "none" 
    }

    /**
     * @dev Retrieves a whitelist instance by its ID.
     * @param whitelistId The ID of the whitelist to retrieve.
     * @return whitelist The whitelist instance.
     */
    function getWhitelistFromWhitelistId(uint32 whitelistId) internal view returns (Whitelist storage whitelist) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(_whitelistExists(whitelistId), "WhitelistFacet: Whitelist not found");
        whitelist = s.whitelists[whitelistId - 1];
    }

    /**
     * @dev Checks if a given address is an admin of a specific whitelist.
     * @param whitelistId The ID of the whitelist to check.
     * @param admin The address to check.
     * @return bool True if the address is an admin, false otherwise.
     */
    function isWhitelistAdmin(uint32 whitelistId, address admin) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isCollectionAdmin[whitelistId][admin] > 0)
        {
            return true;
        }
        else return false;
    }

    /**
     * @dev Checks if a given address is whitelisted.
     * @param whitelistId The ID of the whitelist to check.
     * @param user The address to check.
     * @return uint256 The status of the address in the whitelist.
     */
    function isWhitelisted(uint32 whitelistId, address user) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Whitelist memory whitelist = LibWhitelist.getWhitelistFromWhitelistId(whitelistId);
        uint256 status = s.isWhitelisted[whitelistId][user];
        // if POCSA partener has activated Zenko Whitelist KYC/Legal Contract, 
        // check if user is whitelisted with Zenko Whitelist
        if (status == 0 && whitelist.addZenkoWhiteList == true)
        {
            status = s.isWhitelisted[1][user];
        } 
        return status;
    }

    /**
     * @dev Checks if a whitelist exists by its ID.
     * @param whitelistId The ID of the whitelist to check.
     * @return exists bool True if the whitelist exists, false otherwise.
     */
    function _whitelistExists(uint32 whitelistId) internal view returns (bool exists) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        exists = (s.whitelists.length >= whitelistId) && (whitelistId > 0);
    }

    /**
     * @dev Adds an admin to a specific whitelist.
     * @param _whitelistId The ID of the whitelist to add admin.
     * @param _adminAddress The address of the admin to be added.
     */
    function _addAdminToWhitelist(uint32 _whitelistId, address _adminAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isCollectionAdmin[_whitelistId][_adminAddress] == 0) {
            Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
            whitelist.admins.push(_adminAddress);
            s.isCollectionAdmin[_whitelistId][_adminAddress] = whitelist.admins.length;
        }
    }

    /**
     * @dev Removes an admin from a specific whitelist.
     * @param _whitelistId The ID of the whitelist to remove admin.
     * @param _adminAddress The address of the admin to be removed.
     */
    function _removeAdminFromWhitelist(uint32 _whitelistId, address _adminAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isCollectionAdmin[_whitelistId][_adminAddress] > 0) {
            Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);

            uint256 index = s.isCollectionAdmin[_whitelistId][_adminAddress] - 1;
            uint256 lastIndex = whitelist.admins.length - 1;
            // Replaces the element to be removed with the last element
            whitelist.admins[index] = whitelist.admins[lastIndex];
            // Store the last element in memory
            address lastElement = whitelist.admins[lastIndex];
            // Remove the last element from storage
            whitelist.admins.pop();
            // Update the index of the last element that was swapped. If this is the only element, updates to zero on the next line
            s.isCollectionAdmin[_whitelistId][lastElement] = index + 1;
            // Update the index of the removed element
            s.isCollectionAdmin[_whitelistId][_adminAddress] = 0;
        }
    }

    /**
     * @dev Adds an address to a specific whitelist.
     * @param _whitelistId The ID of the whitelist to add the address.
     * @param _whitelistAddress The address to be added to the whitelist.
     */
    function _addAddressToWhitelist(uint32 _whitelistId, address _whitelistAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isWhitelisted[_whitelistId][_whitelistAddress] == 0) {
            Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
            whitelist.addresses.push(_whitelistAddress);
            s.isWhitelisted[_whitelistId][_whitelistAddress] = whitelist.addresses.length; // Index of the whitelist entry + 1
        }
    }

    /**
     * @dev Removes an address from a specific whitelist.
     * @param _whitelistId The ID of the whitelist to remove the address.
     * @param _whitelistAddress The address to be removed from the whitelist.
     */
    function _removeAddressFromWhitelist(uint32 _whitelistId, address _whitelistAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isWhitelisted[_whitelistId][_whitelistAddress] > 0) {
            Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
            uint256 index = s.isWhitelisted[_whitelistId][_whitelistAddress] - 1;
            uint256 lastIndex = whitelist.addresses.length - 1;
            // Replaces the element to be removed with the last element
            whitelist.addresses[index] = whitelist.addresses[lastIndex];
            // Store the last element in memory
            address lastElement = whitelist.addresses[lastIndex];
            // Remove the last element from storage
            whitelist.addresses.pop();
            // Update the index of the last element that was swapped. If this is the only element, updates to zero on the next line
            s.isWhitelisted[_whitelistId][lastElement] = index + 1;
            // Update the index of the removed element
            s.isWhitelisted[_whitelistId][_whitelistAddress] = 0;
        }
    }

    /**
     * @dev Adds multiple admins to a specific whitelist.
     * @param _whitelistId The ID of the whitelist to add admins.
     * @param _adminAddresses An array of admin addresses to be added.
     */
    function _addAdminsToWhiteList(uint32 _whitelistId, address[] memory _adminAddresses) internal {
        for (uint256 i; i < _adminAddresses.length; i++) {
            _addAdminToWhitelist(_whitelistId, _adminAddresses[i]);
        }
    }

    /**
     * @dev Removes multiple admins from a specific whitelist.
     * @param _whitelistId The ID of the whitelist to remove admins.
     * @param _adminAddresses An array of admin addresses to be removed.
     */

    function _removeAdminsFromWhitelist(uint32 _whitelistId, address[] memory _adminAddresses) internal {
        for (uint256 i; i < _adminAddresses.length; i++) {
            _removeAddressFromWhitelist(_whitelistId, _adminAddresses[i]);
        }
    }

    /**
     * @dev Adds multiple addresses to a specific whitelist.
     * @param _whitelistId The ID of the whitelist to add addresses.
     * @param _whitelistAddresses An array of addresses to be added to the whitelist.
     */
    function _addAddressesToWhitelist(uint32 _whitelistId, address[] memory _whitelistAddresses) internal {
        for (uint256 i; i < _whitelistAddresses.length; i++) {
            _addAddressToWhitelist(_whitelistId, _whitelistAddresses[i]);
        }
    }

    /**
     * @dev Removes multiple addresses from a specific whitelist.
     * @param _whitelistId The ID of the whitelist to remove addresses.
     * @param _whitelistAddresses An array of addresses to be removed from the whitelist.
     */
    function _removeAddressesFromWhitelist(uint32 _whitelistId, address[] memory _whitelistAddresses) internal {
        for (uint256 i; i < _whitelistAddresses.length; i++) {
            _removeAddressFromWhitelist(_whitelistId, _whitelistAddresses[i]);
        }
    }
}