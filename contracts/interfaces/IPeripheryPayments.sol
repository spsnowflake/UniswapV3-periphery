// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;

/// （翻译）标题：外围支付
/// （翻译）说明：方便存入和取出 ETH 的函数
interface IPeripheryPayments {
    /// （翻译）说明：把合约持有的 WETH9 余额解包，并以 ETH 发给接收方。
    /// （翻译）开发说明：amountMinimum 用来防止恶意合约偷走用户的 WETH9。
    /// （翻译）参数 amountMinimum：至少要解包的 WETH9 数量
    /// （翻译）参数 recipient：接收 ETH 的地址
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    /// （翻译）说明：把本合约持有的全部 ETH 余额退回 msg.sender
    /// （翻译）开发说明：适合和用 ETH 铸造、增加流动性，或精确输出兑换打包在一起
    /// （翻译）也就是用 ETH 作为输入数量的那些操作
    function refundETH() external payable;

    /// （翻译）说明：把本合约持有的某种代币的全部余额转给接收方
    /// （翻译）开发说明：amountMinimum 用来防止恶意合约偷走用户的代币
    /// （翻译）参数 token：将转给 recipient 的代币合约地址
    /// （翻译）参数 amountMinimum：转账要求的最小代币数量
    /// （翻译）参数 recipient：代币的目的地址
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}
