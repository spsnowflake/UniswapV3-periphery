// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

/// （翻译）标题：Tick Lens
/// （翻译）说明：提供按块拉取某个池子 tick 数据的函数
/// （翻译）开发说明：这样就不用先拉 tick 位图、解析位图才知道要拉哪些 tick，然后再
/// （翻译）额外发多次 multicall 去拉 tick 数据
interface ITickLens {
    struct PopulatedTick {
        int24 tick;
        int128 liquidityNet;
        uint128 liquidityGross;
    }

    /// （翻译）说明：从一个池子 tick 位图的一个 word 里，取出所有已占用 tick 的数据
    /// （翻译）参数 pool：要拉取已占用 tick 数据的池子地址
    /// （翻译）参数 tickBitmapIndex：tick 位图中要解析的那个 word 的下标，解析后
    /// （翻译）把其中所有已占用的 tick 都取出来
    /// （翻译）返回 populatedTicks：tick 位图中该 word 对应的 tick 数据数组
    function getPopulatedTicksInWord(address pool, int16 tickBitmapIndex)
        external
        view
        returns (PopulatedTick[] memory populatedTicks);
}
