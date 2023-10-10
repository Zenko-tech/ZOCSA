// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ERC20TestContract is ERC20, Ownable {
    constructor(address to, uint256 amount) ERC20("Test Token", "TT") {mint(to, amount);}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}