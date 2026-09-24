// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '../lens/TickLens.sol';

/// （翻译）标题：Tick Lens 合约
contract TickLensTest is TickLens {
    function getGasCostOfGetPopulatedTicksInWord(address pool, int16 tickBitmapIndex) external view returns (uint256) {
        uint256 gasBefore = gasleft();
        getPopulatedTicksInWord(pool, tickBitmapIndex);
        return gasBefore - gasleft();
    }
}
