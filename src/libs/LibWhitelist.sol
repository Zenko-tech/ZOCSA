// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Whitelist } from "../shared/Structs.sol";
import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";

library LibWhitelist {

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

    function addZenkoWhitelistToPOCSA(uint32 _whitelistId) internal {
        Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
        whitelist.addZenkoWhiteList = true;
    }

    function getNewWhitelistId() internal view returns (uint32 whitelistId) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        whitelistId = uint32(s.whitelists.length + 1); //whitelistId 0 is reserved for "none" 
    }

    function getWhitelistFromWhitelistId(uint32 whitelistId) internal view returns (Whitelist storage whitelist) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(_whitelistExists(whitelistId), "WhitelistFacet: Whitelist not found");
        whitelist = s.whitelists[whitelistId - 1];
    }

    function isWhitelistAdmin(uint32 whitelistId, address admin) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isCollectionAdmin[whitelistId][admin] > 0)
        {
            return true;
        }
        else return false;
    }
    
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

    function _whitelistExists(uint32 whitelistId) internal view returns (bool exists) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        exists = (s.whitelists.length >= whitelistId) && (whitelistId > 0);
    }

    function _addAdminToWhitelist(uint32 _whitelistId, address _adminAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isCollectionAdmin[_whitelistId][_adminAddress] == 0) {
            Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
            whitelist.admins.push(_adminAddress);
            s.isCollectionAdmin[_whitelistId][_adminAddress] = whitelist.admins.length;
        }
    }

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

    function _addAddressToWhitelist(uint32 _whitelistId, address _whitelistAddress) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.isWhitelisted[_whitelistId][_whitelistAddress] == 0) {
            Whitelist storage whitelist = LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
            whitelist.addresses.push(_whitelistAddress);
            s.isWhitelisted[_whitelistId][_whitelistAddress] = whitelist.addresses.length; // Index of the whitelist entry + 1
        }
    }

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

    function _addAdminsToWhiteList(uint32 _whitelistId, address[] memory _adminAddresses) internal {
        for (uint256 i; i < _adminAddresses.length; i++) {
            _addAdminToWhitelist(_whitelistId, _adminAddresses[i]);
        }
    }

    function _removeAdminsFromWhitelist(uint32 _whitelistId, address[] memory _adminAddresses) internal {
        for (uint256 i; i < _adminAddresses.length; i++) {
            _removeAddressFromWhitelist(_whitelistId, _adminAddresses[i]);
        }
    }

    function _addAddressesToWhitelist(uint32 _whitelistId, address[] memory _whitelistAddresses) internal {
        for (uint256 i; i < _whitelistAddresses.length; i++) {
            _addAddressToWhitelist(_whitelistId, _whitelistAddresses[i]);
        }
    }

    function _removeAddressesFromWhitelist(uint32 _whitelistId, address[] memory _whitelistAddresses) internal {
        for (uint256 i; i < _whitelistAddresses.length; i++) {
            _removeAddressFromWhitelist(_whitelistId, _whitelistAddresses[i]);
        }
    }
}