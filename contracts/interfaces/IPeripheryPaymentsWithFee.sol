// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;

import './IPeripheryPayments.sol';

/// （翻译）标题：外围支付
/// （翻译）说明：方便存入和取出 ETH 的函数
interface IPeripheryPaymentsWithFee is IPeripheryPayments {
    /// （翻译）说明：把合约的 WETH9 余额解包成 ETH 发给接收方，并把其中一定比例分给手续费接收方，比例介于
    /// （翻译）0（不含）到 1（含）之间，分给 feeRecipient
    /// （翻译）开发说明：amountMinimum 用来防止恶意合约偷走用户的 WETH9。
    function unwrapWETH9WithFee(
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;

    /// （翻译）说明：把本合约持有的某种代币全部转给接收方，并把其中一定比例分给手续费接收方，比例介于
    /// （翻译）0（不含）到 1（含）之间，分给 feeRecipient
    /// （翻译）开发说明：amountMinimum 用来防止恶意合约偷走用户的代币
    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;
}
