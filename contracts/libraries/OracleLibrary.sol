// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0 <0.8.0;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

/// （翻译）标题：预言机库
/// （翻译）说明：提供与 V3 池子预言机交互的函数
library OracleLibrary {
    /// （翻译）说明：计算指定 Uniswap V3 池子的 tick 与流动性的时间加权平均
    /// （翻译）参数 pool：要观察的池子地址
    /// （翻译）参数 secondsAgo：从多少秒之前开始，计算到现在的时间加权平均
    /// （翻译）返回 arithmeticMeanTick：从 block.timestamp - secondsAgo 到 block.timestamp 的 tick 算术平均
    /// （翻译）返回 harmonicMeanLiquidity：同一时间段内流动性的调和平均
    function consult(address pool, uint32 secondsAgo)
        internal
        view
        returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity)
    {
        require(secondsAgo != 0, 'BP');

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) =
            IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerLiquidityCumulativesDelta =
            secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];

        arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
        // （翻译）始终向负无穷方向取整
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;

        // （翻译）这里用乘法而不是移位，是为了保证 harmonicMeanLiquidity 不会溢出 uint128
        uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
        harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
    }

    /// （翻译）说明：给定 tick 和一种代币数量，计算兑换能得到的另一种代币数量
    /// （翻译）参数 tick：用来计算报价的 tick
    /// （翻译）参数 baseAmount：要换算的代币数量
    /// （翻译）参数 baseToken：baseAmount 所计价的 ERC20 合约地址
    /// （翻译）参数 quoteToken：quoteAmount 所计价的 ERC20 合约地址
    /// （翻译）返回 quoteAmount：用 baseAmount 数量的 baseToken 能换到的 quoteToken 数量
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // （翻译）如果平方根价格自乘不会溢出，就用更高精度来计算 quoteAmount
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    /// （翻译）说明：给定池子，返回它存着的最老一条观察值距离现在多少秒
    /// （翻译）参数 pool：要观察的 Uniswap V3 池子地址
    /// （翻译）返回 secondsAgo：该池子所存最老观察值距今的秒数
    function getOldestObservationSecondsAgo(address pool) internal view returns (uint32 secondsAgo) {
        (, , uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
        require(observationCardinality > 0, 'NI');

        (uint32 observationTimestamp, , , bool initialized) =
            IUniswapV3Pool(pool).observations((observationIndex + 1) % observationCardinality);

        // （翻译）如果观察值容量 cardinality 正在扩大，下一个下标可能还没初始化
        // （翻译）这时最老的观察值一定在下标 0
        if (!initialized) {
            (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
        }

        secondsAgo = uint32(block.timestamp) - observationTimestamp;
    }

    /// （翻译）说明：给定池子，返回当前区块开始时的 tick
    /// （翻译）参数 pool：Uniswap V3 池子地址
    /// （翻译）返回：当前区块开始时池子所在的 tick
    function getBlockStartingTickAndLiquidity(address pool) internal view returns (int24, uint128) {
        (, int24 tick, uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();

        // （翻译）要可靠算出区块开始时的 tick，至少需要 2 条观察值
        require(observationCardinality > 1, 'NEO');

        // （翻译）如果最新观察值发生在过去，说明本区块还没有改变 tick 的成交
        // （翻译）因此 slot0 里的 tick 就等于当前区块开始时的 tick。
        // （翻译）不需要再检查这条观察值有没有初始化，它一定已经初始化了。
        (uint32 observationTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, ) =
            IUniswapV3Pool(pool).observations(observationIndex);
        if (observationTimestamp != uint32(block.timestamp)) {
            return (tick, IUniswapV3Pool(pool).liquidity());
        }

        uint256 prevIndex = (uint256(observationIndex) + observationCardinality - 1) % observationCardinality;
        (
            uint32 prevObservationTimestamp,
            int56 prevTickCumulative,
            uint160 prevSecondsPerLiquidityCumulativeX128,
            bool prevInitialized
        ) = IUniswapV3Pool(pool).observations(prevIndex);

        require(prevInitialized, 'ONI');

        uint32 delta = observationTimestamp - prevObservationTimestamp;
        tick = int24((tickCumulative - prevTickCumulative) / delta);
        uint128 liquidity =
            uint128(
                (uint192(delta) * type(uint160).max) /
                    (uint192(secondsPerLiquidityCumulativeX128 - prevSecondsPerLiquidityCumulativeX128) << 32)
            );
        return (tick, liquidity);
    }

    /// （翻译）说明：用来计算加权算术平均 tick 的数据
    struct WeightedTickData {
        int24 tick;
        uint128 weight;
    }

    /// （翻译）说明：给定一组 tick 和权重，计算加权算术平均 tick
    /// （翻译）参数 weightedTickData：tick 与权重组成的数组
    /// （翻译）返回 weightedArithmeticMeanTick：加权算术平均 tick
    /// （翻译）开发说明：weightedTickData 的每一项都应当来自底层代币相同的池子。如果不是，
    /// （翻译）就必须非常小心地保证这些 tick 可以比较（包括小数位差异）。
    /// （翻译）开发说明：加权算术平均 tick 对应的是价格的加权几何平均。
    function getWeightedArithmeticMeanTick(WeightedTickData[] memory weightedTickData)
        internal
        pure
        returns (int24 weightedArithmeticMeanTick)
    {
        // （翻译）累加每一项 tick 乘以权重的乘积
        int256 numerator;

        // （翻译）累加权重之和
        uint256 denominator;

        // （翻译）每一项乘积放得进 152 位，所以数组长度要到大约 2**104 才会让这段逻辑溢出
        for (uint256 i; i < weightedTickData.length; i++) {
            numerator += weightedTickData[i].tick * int256(weightedTickData[i].weight);
            denominator += weightedTickData[i].weight;
        }

        weightedArithmeticMeanTick = int24(numerator / int256(denominator));
        // （翻译）始终向负无穷方向取整
        if (numerator < 0 && (numerator % int256(denominator) != 0)) weightedArithmeticMeanTick--;
    }

    /// （翻译）说明：返回“合成”tick，表示 tokens 数组第一项代币用最后一项计价的价格
    /// （翻译）开发说明：适合用来计算一条路径上的相对价格。
    /// （翻译）开发说明：每一对相邻代币都必须有一个 tick。
    /// （翻译）参数 tokens：代币合约地址
    /// （翻译）参数 ticks：tick 数组，表示 tokens 里每一对代币的价格
    /// （翻译）返回 syntheticTick：合成 tick，表示 tokens 两端代币的相对价格
    function getChainedPrice(address[] memory tokens, int24[] memory ticks)
        internal
        pure
        returns (int256 syntheticTick)
    {
        require(tokens.length - 1 == ticks.length, 'DL');
        for (uint256 i = 1; i <= ticks.length; i++) {
            // （翻译）先看代币地址的排序，再把
            // （翻译）这些 tick 累加进正在计算的合成 tick，让中间代币互相抵消
            tokens[i - 1] < tokens[i] ? syntheticTick += ticks[i - 1] : syntheticTick -= ticks[i - 1];
        }
    }
}
