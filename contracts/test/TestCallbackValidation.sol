// SPDX-License-Identifier: UNLICENSED
// （翻译）SPDX 许可证标识：未授予开源许可证（测试或私有代码）
pragma solidity =0.7.6;

import '../libraries/CallbackValidation.sol';

contract TestCallbackValidation {
    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (IUniswapV3Pool pool) {
        return CallbackValidation.verifyCallback(factory, tokenA, tokenB, fee);
    }
}
