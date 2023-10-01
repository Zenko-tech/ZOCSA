// SPDX-License-Identifier: MIT
// Source: // https://gist.github.com/AlmostEfficient/669ac250214f30347097a1aeedcdfa12
pragma solidity >=0.8.21;

import "./LibMath.sol";

library LibString {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
  /**
   * @dev Returns the length of a given string
   *
   * @param s The string to measure the length of
   * @return The length of the input string
   */
  function len(string memory s) internal pure returns (uint) {
    uint length;
    uint i = 0;
    uint bytelength = bytes(s).length;
    for (length = 0; i < bytelength; length++) {
      bytes1 b = bytes(s)[i];
      if (b < 0x80) {
        i += 1;
      } else if (b < 0xE0) {
        i += 2;
      } else if (b < 0xF0) {
        i += 3;
      } else if (b < 0xF8) {
        i += 4;
      } else if (b < 0xFC) {
        i += 5;
      } else {
        i += 6;
      }
    }
    return length;
  }

      /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function addrToString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(42); // Adjusted size
    s[0] = '0';
    s[1] = 'x';
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i+2] = char(hi);  // Adjusted indices
        s[2*i+3] = char(lo);  // Adjusted indices           
    }
    return string(s);
}
function char(bytes1 b) internal pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
}
}
