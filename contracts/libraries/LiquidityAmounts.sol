// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@uniswap/v3-core/contracts/libraries/FixedPoint96.sol';

/// （翻译）标题：流动性数量函数
/// （翻译）说明：根据代币数量和价格计算流动性数量的函数
library LiquidityAmounts {
    /// （翻译）说明：把 uint256 向下收窄成 uint128
    /// （翻译）参数 x：要向下收窄的整数（原文写成 uint258，实际类型是 uint256）
    /// （翻译）返回 y：传入的值，已收窄为 uint128
    function toUint128(uint256 x) private pure returns (uint128 y) {
        require((y = uint128(x)) == x);
    }

    /// （翻译）说明：给定 token0 数量和价格区间，计算能得到的流动性
    /// （翻译）开发说明：计算 amount0 * (sqrt(upper) * sqrt(lower)) / (sqrt(upper) - sqrt(lower))
    /// （翻译）参数 sqrtRatioAX96：第一个 tick 边界对应的平方根价格
    /// （翻译）参数 sqrtRatioBX96：第二个 tick 边界对应的平方根价格
    /// （翻译）参数 amount0：投入的 token0 数量
    /// （翻译）返回 liquidity：算出来的流动性数量
    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    /// （翻译）说明：给定 token1 数量和价格区间，计算能得到的流动性
    /// （翻译）开发说明：计算 amount1 / (sqrt(upper) - sqrt(lower))。
    /// （翻译）参数 sqrtRatioAX96：第一个 tick 边界对应的平方根价格
    /// （翻译）参数 sqrtRatioBX96：第二个 tick 边界对应的平方根价格
    /// （翻译）参数 amount1：投入的 token1 数量
    /// （翻译）返回 liquidity：算出来的流动性数量
    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    /// （翻译）说明：给定 token0、token1 数量以及当前
    /// （翻译）池子价格和 tick 边界价格，计算能得到的最大流动性
    /// （翻译）参数 sqrtRatioX96：表示池子当前价格的平方根价格
    /// （翻译）参数 sqrtRatioAX96：第一个 tick 边界对应的平方根价格
    /// （翻译）参数 sqrtRatioBX96：第二个 tick 边界对应的平方根价格
    /// （翻译）参数 amount0：投入的 token0 数量
    /// （翻译）参数 amount1：投入的 token1 数量
    /// （翻译）返回 liquidity：能得到的最大流动性
    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    /// （翻译）说明：给定流动性和价格区间，计算对应的 token0 数量
    /// （翻译）参数 sqrtRatioAX96：第一个 tick 边界对应的平方根价格
    /// （翻译）参数 sqrtRatioBX96：第二个 tick 边界对应的平方根价格
    /// （翻译）参数 liquidity：正在估值的流动性
    /// （翻译）返回 amount0：token0 的数量
    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            FullMath.mulDiv(
                uint256(liquidity) << FixedPoint96.RESOLUTION,
                sqrtRatioBX96 - sqrtRatioAX96,
                sqrtRatioBX96
            ) / sqrtRatioAX96;
    }

    /// （翻译）说明：给定流动性和价格区间，计算对应的 token1 数量
    /// （翻译）参数 sqrtRatioAX96：第一个 tick 边界对应的平方根价格
    /// （翻译）参数 sqrtRatioBX96：第二个 tick 边界对应的平方根价格
    /// （翻译）参数 liquidity：正在估值的流动性
    /// （翻译）返回 amount1：token1 的数量
    function getAmount1ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    /// （翻译）说明：给定一定数量的流动性，以及当前
    /// （翻译）池子价格和 tick 边界价格，计算对应的 token0 和 token1 数量
    /// （翻译）参数 sqrtRatioX96：表示池子当前价格的平方根价格
    /// （翻译）参数 sqrtRatioAX96：第一个 tick 边界对应的平方根价格
    /// （翻译）参数 sqrtRatioBX96：第二个 tick 边界对应的平方根价格
    /// （翻译）参数 liquidity：正在估值的流动性
    /// （翻译）返回 amount0：token0 的数量
    /// （翻译）返回 amount1：token1 的数量
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }
}
