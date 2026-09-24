// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// （翻译）标题：WETH9 接口
interface IWETH9 is IERC20 {
    /// （翻译）说明：存入 ETH，得到包装后的 WETH
    function deposit() external payable;

    /// （翻译）说明：取出包装 ETH，换回 ETH
    function withdraw(uint256) external;
}
