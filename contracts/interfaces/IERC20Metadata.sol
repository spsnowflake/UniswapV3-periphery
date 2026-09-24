// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// （翻译）标题：IERC20Metadata
/// （翻译）标题：ERC20 元数据接口
/// （翻译）说明：IERC20 的扩展，包含代币元数据
interface IERC20Metadata is IERC20 {
    /// （翻译）返回：代币名称
    function name() external view returns (string memory);

    /// （翻译）返回：代币符号
    function symbol() external view returns (string memory);

    /// （翻译）返回：代币的小数位数
    function decimals() external view returns (uint8);
}
