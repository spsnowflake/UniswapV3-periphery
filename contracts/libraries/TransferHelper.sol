// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


// 不直接使用IERC20.transferFrom, transfer, 为了兼容那些不按 ERC20 规范返回 bool 的代币。
// 链上有一批老代币并不遵守这个约定，转账成功时不返回任何数据，失败时直接 revert。
// 对这种合约，高层调用会在解码 bool 时失败，整笔交易回滚，即使代币其实已经转成功了。
library TransferHelper {
    /// （翻译）说明：把代币从指定地址转到给定目的地。转账失败时以 'STF' 报错
    /// （翻译）参数 token：要转移的代币合约地址
    /// （翻译）参数 from：代币转出的来源地址
    /// （翻译）参数 to：转账的目的地址
    /// （翻译）参数 value：要转移的数量
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// （翻译）说明：把代币从 msg.sender 转给接收方
    /// （翻译）开发说明：转账失败时以 ST 报错
    /// （翻译）参数 token：将要被转移的代币合约地址
    /// （翻译）参数 to：转账接收方
    /// （翻译）参数 value：转账的数额
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// （翻译）说明：授权指定合约花费给定代币的指定额度
    /// （翻译）开发说明：授权失败时以 'SA' 报错（原文写成 transfer fails）
    /// （翻译）参数 token：要授权的代币合约地址
    /// （翻译）参数 to：被授权的目标地址
    /// （翻译）参数 value：目标地址被允许花费的该代币数量
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// （翻译）说明：把 ETH 转给接收地址
    /// （翻译）开发说明：失败时报错 `STE`
    /// （翻译）参数 to：转账目的地
    /// （翻译）参数 value：要转移的数额
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}
