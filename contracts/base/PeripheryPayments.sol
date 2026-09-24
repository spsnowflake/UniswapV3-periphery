// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IPeripheryPayments.sol';
import '../interfaces/external/IWETH9.sol';

import '../libraries/TransferHelper.sol';

import './PeripheryImmutableState.sol';

abstract contract PeripheryPayments is IPeripheryPayments, PeripheryImmutableState {
    receive() external payable {
        require(msg.sender == WETH9, 'Not WETH9');
    }

    /// （翻译）说明：把合约持有的 WETH9 余额解包，并以 ETH 发给接收方。
    /// （翻译）开发说明：amountMinimum 用来防止恶意合约偷走用户的 WETH9。
    /// （翻译）参数 amountMinimum：至少要解包的 WETH9 数量
    /// （翻译）参数 recipient：接收 ETH 的地址
    function unwrapWETH9(uint256 amountMinimum, address recipient) public payable override {
        uint256 balanceWETH9 = IWETH9(WETH9).balanceOf(address(this));
        require(balanceWETH9 >= amountMinimum, 'Insufficient WETH9');

        if (balanceWETH9 > 0) {
            IWETH9(WETH9).withdraw(balanceWETH9);
            TransferHelper.safeTransferETH(recipient, balanceWETH9);
        }
    }

    /// （翻译）说明：把本合约持有的某种代币的全部余额转给接收方
    /// （翻译）开发说明：amountMinimum 用来防止恶意合约偷走用户的代币
    /// （翻译）参数 token：将转给 recipient 的代币合约地址
    /// （翻译）参数 amountMinimum：转账要求的最小代币数量
    /// （翻译）参数 recipient：代币的目的地址
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) public payable override {
        uint256 balanceToken = IERC20(token).balanceOf(address(this));
        require(balanceToken >= amountMinimum, 'Insufficient token');

        if (balanceToken > 0) {
            TransferHelper.safeTransfer(token, recipient, balanceToken);
        }
    }

    /// （翻译）说明：把本合约持有的全部 ETH 余额退回 msg.sender
    /// （翻译）开发说明：适合和用 ETH 铸造、增加流动性，或精确输出兑换打包在一起
    /// （翻译）也就是用 ETH 作为输入数量的那些操作
    function refundETH() external payable override {
        if (address(this).balance > 0) TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    /// （翻译）参数 token：要支付的代币
    /// （翻译）参数 payer：必须付款的一方
    /// （翻译）参数 recipient：接收付款的一方
    /// （翻译）参数 value：支付数量
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            // （翻译）用 WETH9 支付
            IWETH9(WETH9).deposit{value: value}();
            // （翻译）只把这次付款需要的 ETH 包装成 WETH9
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            // （翻译）用合约里已经有的代币支付（精确输入多跳的情况）
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            // （翻译）从付款人地址拉取代币来支付
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
}
