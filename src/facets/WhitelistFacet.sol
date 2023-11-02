// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Whitelist } from "../shared/Structs.sol";
import { LibWhitelist } from "../libs/LibWhitelist.sol";
import { AccessControl } from "../shared/AccessControl.sol";
import { ReentrancyGuard } from "../shared/ReentrancyGuard.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
import { LibString } from "../libs/LibString.sol";

contract WhitelistFacet is AccessControl, ReentrancyGuard {
    event WhitelistUpdated(uint32 indexed whitelistId);

    /**
     * @dev Adds admins to a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     * @param _adminAddresses The addresses of the admins to be added.
     */
    function addAdminsToWhitelist(uint32 _whitelistId, address[] calldata _adminAddresses) external {
        require(_adminAddresses.length > 0, "WhitelistFacet: _adminAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._addAddressesToWhitelist(_whitelistId, _adminAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    /**
     * @dev Removes admins from a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     * @param _adminAddresses The addresses of the admins to be removed.
     */
    function removeAdminsFromWhitelist(uint32 _whitelistId, address[] calldata _adminAddresses) external {
        require(_adminAddresses.length > 0, "WhitelistFacet: _adminAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._removeAddressesFromWhitelist(_whitelistId, _adminAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    /**
     * @dev Adds addresses to a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     * @param _whitelistAddresses The addresses to be added to the whitelist.
     */
    function addAddressesToWhitelist(uint32 _whitelistId, address[] calldata _whitelistAddresses) external {
        require(_whitelistAddresses.length > 0, "WhitelistFacet: _whitelistAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._addAddressesToWhitelist(_whitelistId, _whitelistAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    /**
     * @dev Removes addresses from a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     * @param _whitelistAddresses The addresses to be removed from the whitelist.
     */
    function removeAddressesFromWhitelist(uint32 _whitelistId, address[] calldata _whitelistAddresses) external {
        require(_whitelistAddresses.length > 0, "WhitelistFacet: _whitelistAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._removeAddressesFromWhitelist(_whitelistId, _whitelistAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    /**
     * @dev Adds Zenko whitelist to a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     */
    function addZenkoWhitelist(uint32 _whitelistId) external {
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");
        LibWhitelist.addZenkoWhitelistToPOCSA(_whitelistId);
    }

    /**
     * @dev Checks if a whitelist exists.
     * @param _whitelistId The ID of the whitelist.
     * @return bool True if the whitelist exists, false otherwise.
     */
    function whitelistExists(uint32 _whitelistId) external view returns (bool exists) {
        exists = LibWhitelist._whitelistExists(_whitelistId);
    }

    // 0 is non whitelisted, else return position in whitelist
        /**
     * @dev Checks if an address is whitelisted.
     * @param _whitelistId The ID of the whitelist.
     * @param _whitelistAddress The address to check.
     * @return uint256 Position of the address in the whitelist, 0 if not whitelisted.
     */
    function isWhitelisted(uint32 _whitelistId, address _whitelistAddress) external view returns (uint256 position) {
        position = LibWhitelist.isWhitelisted(_whitelistId, _whitelistAddress);
    }

    /**
     * @dev Returns the total number of whitelists.
     * @return uint256 The total number of whitelists.
     */
    function getWhitelistsLength() external view returns (uint256 length) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        length = s.whitelists.length;
    }

    /**
     * @dev Retrieves information about a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     * @return Whitelist The information about the whitelist.
     */
    function getWhitelistInfos(uint32 _whitelistId) external view returns (Whitelist memory) {
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        return LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
    }

    /**
     * @dev Checks if a user is an admin of a specific whitelist.
     * @param _whitelistId The ID of the whitelist.
     * @param _user The address of the user.
     * @return bool True if the user is an admin, false otherwise.
     */
    function isWhitelistAdmin(uint32 _whitelistId, address _user) external view returns (bool status) {
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        status = LibWhitelist.isWhitelistAdmin(_whitelistId, _user);
    }
}