// SPDX-License-Identifier: MIT
// （翻译）SPDX 许可证标识：MIT 许可证
pragma solidity =0.7.6;

library HexStrings {
    bytes16 internal constant ALPHABET = '0123456789abcdef';

    /// （翻译）说明：把 uint256 转成固定长度的 ASCII 十六进制字符串。
    /// （翻译）开发说明：致谢 OpenZeppelin，MIT 许可证，见 https://github.com/OpenZeppelin/openzeppelin-contracts/blob/243adff49ce1700e0ecb99fe522fb16cff1d1ddc/contracts/utils/Strings.sol#L55
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        require(value == 0, 'Strings: hex length insufficient');
        return string(buffer);
    }

    function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length);
        for (uint256 i = buffer.length; i > 0; i--) {
            buffer[i - 1] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}
