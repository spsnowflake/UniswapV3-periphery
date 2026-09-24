// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@uniswap/v3-core/contracts/libraries/UnsafeMath.sol';
import '@uniswap/v3-core/contracts/libraries/FixedPoint96.sol';

/// （翻译）标题：基于 Q64.96 平方根价格和流动性的函数
/// （翻译）说明：从 @uniswap/v3-core 的 SqrtPriceMath 中露出两个函数
/// （翻译）它们用 Q64.96 格式的价格平方根和流动性来计算数量差
library SqrtPriceMathPartial {
    /// （翻译）说明：计算两个价格之间的 token0 数量差
    /// （翻译）开发说明：计算 liquidity / sqrt(lower) - liquidity / sqrt(upper)，
    /// （翻译）也就是 liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))
    /// （翻译）参数 sqrtRatioAX96：一个平方根价格
    /// （翻译）参数 sqrtRatioBX96：另一个平方根价格
    /// （翻译）参数 liquidity：可用流动性数量
    /// （翻译）参数 roundUp：数量向上取整还是向下取整
    /// （翻译）返回 amount0：在这两个价格之间覆盖这么多流动性所需的 token0 数量
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

        require(sqrtRatioAX96 > 0);

        return
            roundUp
                ? UnsafeMath.divRoundingUp(
                    FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
                    sqrtRatioAX96
                )
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
    }

    /// （翻译）说明：计算两个价格之间的 token1 数量差
    /// （翻译）开发说明：计算 liquidity * (sqrt(upper) - sqrt(lower))
    /// （翻译）参数 sqrtRatioAX96：一个平方根价格
    /// （翻译）参数 sqrtRatioBX96：另一个平方根价格
    /// （翻译）参数 liquidity：可用流动性数量
    /// （翻译）参数 roundUp：数量向上取整，还是向下取整
    /// （翻译）返回 amount1：在这两个价格之间覆盖这么多流动性所需的 token1 数量
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }
}
