// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;

import '../interfaces/IPeripheryImmutableState.sol';

/// （翻译）标题：不可变状态
/// （翻译）说明：外围合约使用的不可变状态
abstract contract PeripheryImmutableState is IPeripheryImmutableState {
    /// （翻译）IPeripheryImmutableState
    address public immutable override factory;
    /// （翻译）IPeripheryImmutableState
    address public immutable override WETH9;

    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }
}
