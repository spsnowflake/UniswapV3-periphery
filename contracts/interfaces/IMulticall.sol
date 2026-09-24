// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

/// （翻译）标题：Multicall 接口
/// （翻译）说明：允许在一次合约调用里执行多个方法
interface IMulticall {
    /// （翻译）说明：调用当前合约的多个函数，若全部成功则返回它们的全部数据
    /// （翻译）开发说明：任何能从 multicall 调到的方法，都不应当信任 msg.value。
    /// （翻译）参数 data：要对本合约发起的每一次调用的编码函数数据
    /// （翻译）返回 results：通过 data 传入的每一次调用的结果
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}
