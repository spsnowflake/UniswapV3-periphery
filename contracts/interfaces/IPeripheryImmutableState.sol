// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

/// （翻译）标题：不可变状态
/// （翻译）说明：返回路由器不可变状态的函数
interface IPeripheryImmutableState {
    /// （翻译）返回：Uniswap V3 工厂的地址
    function factory() external view returns (address);

    /// （翻译）返回：WETH9 的地址
    function WETH9() external view returns (address);
}
