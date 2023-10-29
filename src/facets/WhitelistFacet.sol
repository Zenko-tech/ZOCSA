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

    function addAdminsToWhitelist(uint32 _whitelistId, address[] calldata _adminAddresses) external {
        require(_adminAddresses.length > 0, "WhitelistFacet: _adminAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._addAddressesToWhitelist(_whitelistId, _adminAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    function removeAdminsFromWhitelist(uint32 _whitelistId, address[] calldata _adminAddresses) external {
        require(_adminAddresses.length > 0, "WhitelistFacet: _adminAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._removeAddressesFromWhitelist(_whitelistId, _adminAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    function addAddressesToWhitelist(uint32 _whitelistId, address[] calldata _whitelistAddresses) external {
        require(_whitelistAddresses.length > 0, "WhitelistFacet: _whitelistAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._addAddressesToWhitelist(_whitelistId, _whitelistAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    function removeAddressesFromWhitelist(uint32 _whitelistId, address[] calldata _whitelistAddresses) external {
        require(_whitelistAddresses.length > 0, "WhitelistFacet: _whitelistAddresses must contain more than 0 address");
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        require(LibWhitelist.isWhitelistAdmin(_whitelistId, _msgSender()), "WhitelistFacet: Not whitelisted admin");

        LibWhitelist._removeAddressesFromWhitelist(_whitelistId, _whitelistAddresses);

        emit WhitelistUpdated(_whitelistId);
    }

    function whitelistExists(uint32 whitelistId) external view returns (bool exists) {
        exists = LibWhitelist._whitelistExists(whitelistId);
    }

    // 0 is non whitelisted, else return position in whitelist
    function isWhitelisted(uint32 _whitelistId, address _whitelistAddress) external view returns (uint256 position) {
        position = LibWhitelist.isWhitelisted(_whitelistId, _whitelistAddress);
    }

    function getWhitelistsLength() external view returns (uint256 length) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        length = s.whitelists.length;
    }

    function getWhitelistInfos(uint32 _whitelistId) external view returns (Whitelist memory) {
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        return LibWhitelist.getWhitelistFromWhitelistId(_whitelistId);
    }

    function isWhitelistAdmin(uint32 _whitelistId, address _user) external view returns (bool status) {
        require(LibWhitelist._whitelistExists(_whitelistId), "WhitelistFacet: Whitelist not found");
        status = LibWhitelist.isWhitelistAdmin(_whitelistId, _user);
    }
}