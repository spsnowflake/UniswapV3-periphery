// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

/// （翻译）标题：创建并初始化 V3 池子
/// （翻译）说明：提供一个在必要时创建并初始化池子的方法，以便和别的方法打包，那些方法
/// （翻译）要求池子已经存在。
interface IPoolInitializer {
    /// （翻译）说明：如果池子不存在就创建，如果还没初始化就初始化
    /// （翻译）开发说明：这个方法可以通过 IMulticall 和其他方法打包，用于对一个池子做的第一个动作（例如 mint）
    /// （翻译）参数 token0：池子 token0 的合约地址
    /// （翻译）参数 token1：池子 token1 的合约地址
    /// （翻译）参数 fee：指定代币对的 V3 池子手续费数量
    /// （翻译）参数 sqrtPriceX96：池子的初始平方根价格，Q64.96 格式
    /// （翻译）返回 pool：根据代币对和手续费返回池子地址；如有必要，返回新建池子的地址
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}
