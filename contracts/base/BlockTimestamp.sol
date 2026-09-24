// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;

/// （翻译）标题：获取区块时间戳的函数
/// （翻译）开发说明：基类合约，测试时会被重写
abstract contract BlockTimestamp {
    /// （翻译）开发说明：这个方法存在的唯一目的，就是让测试可以重写它
    /// （翻译）返回：当前区块时间戳
    function _blockTimestamp() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
