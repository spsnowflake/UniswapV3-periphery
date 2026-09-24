// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.6.0;

import './BytesLib.sol';

/// （翻译）标题：处理多跳兑换路径数据的函数
library Path {
    using BytesLib for bytes;

    // （翻译）开发说明：编码后的地址所占字节长度
    uint256 private constant ADDR_SIZE = 20;
    // （翻译）开发说明：编码后的手续费所占字节长度
    uint256 private constant FEE_SIZE = 3;

    // （翻译）开发说明：一个代币地址加一个池子手续费的偏移量
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    // （翻译）开发说明：编码后的一个池子键的偏移量
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    // （翻译）开发说明：包含 2 个或更多池子的编码的最小长度
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    /// （翻译）说明：当且仅当路径包含两个或更多池子时返回 true
    /// （翻译）参数 path：编码后的兑换路径
    /// （翻译）返回：路径包含两个或更多池子则为 true，否则为 false
    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    /// （翻译）说明：返回路径里的池子数量
    /// （翻译）参数 path：编码后的兑换路径
    /// （翻译）返回：路径里的池子数量
    function numPools(bytes memory path) internal pure returns (uint256) {
        // （翻译）忽略第一个代币地址。从那以后，每一段手续费加代币偏移都表示一个池子。
        return ((path.length - ADDR_SIZE) / NEXT_OFFSET);
    }

    /// （翻译）说明：解码路径中的第一个池子
    /// （翻译）参数 path：按字节编码的兑换路径
    /// （翻译）返回 tokenA：该池子的第一个代币
    /// （翻译）返回 tokenB：该池子的第二个代币
    /// （翻译）返回 fee：该池子的手续费档位
    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {
        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    /// （翻译）说明：取出路径中对应第一个池子的那一段
    /// （翻译）参数 path：按字节编码的兑换路径
    /// （翻译）返回：包含定位路径中第一个池子所需全部数据的那一段
    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    /// （翻译）说明：从缓冲区跳过一个代币加手续费元素，返回剩下的部分
    /// （翻译）参数 path：兑换路径
    /// （翻译）返回：路径里剩余的代币加手续费元素
    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}
