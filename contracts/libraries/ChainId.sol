// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.0;

/// （翻译）标题：获取当前链 ID 的函数
library ChainId {
    /// （翻译）开发说明：读取当前链 ID
    /// （翻译）返回 chainId：当前链 ID
    function get() internal pure returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
}
