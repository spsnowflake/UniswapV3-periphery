// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.6.0;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

library PoolTicksCounter {
    /// （翻译）开发说明：这个函数统计 tickBefore 和 tickAfter 之间、会产生 gas 消耗的已初始化 tick 数量。
    /// （翻译）如果 tickBefore 和/或 tickAfter 本身已初始化，要不要把它们算进去取决于
    /// （翻译）兑换方向。向上兑换（tickAfter > tickBefore）时不算 tickBefore，但要
    /// （翻译）算 tickAfter。向下兑换时则相反。
    function countInitializedTicksCrossed(
        IUniswapV3Pool self,
        int24 tickBefore,
        int24 tickAfter
    ) internal view returns (uint32 initializedTicksCrossed) {
        int16 wordPosLower;
        int16 wordPosHigher;
        uint8 bitPosLower;
        uint8 bitPosHigher;
        bool tickBeforeInitialized;
        bool tickAfterInitialized;

        {
            // （翻译）取出兑换前、兑换后活跃 tick 在 tick 位图里的 word 下标和位偏移。
            int16 wordPos = int16((tickBefore / self.tickSpacing()) >> 8);
            uint8 bitPos = uint8((tickBefore / self.tickSpacing()) % 256);

            int16 wordPosAfter = int16((tickAfter / self.tickSpacing()) >> 8);
            uint8 bitPosAfter = uint8((tickAfter / self.tickSpacing()) % 256);

            // （翻译）如果 tickAfter 已初始化，只有向下兑换时才把它算进去。
            // （翻译）如果兑换后那个可初始化 tick 已经初始化，而我们原来的 tickAfter 是
            // （翻译）tickSpacing 的整数倍，并且正在向下兑换，那就知道 tickAfter 已初始化
            // （翻译）并且不应当把它算进去。
            tickAfterInitialized =
                ((self.tickBitmap(wordPosAfter) & (1 << bitPosAfter)) > 0) &&
                ((tickAfter % self.tickSpacing()) == 0) &&
                (tickBefore > tickAfter);

            // （翻译）如果 tickBefore 已初始化，只有向上兑换时才把它算进去。
            // （翻译）用和上面相同的逻辑，决定要不要把 tickBefore 算进去。
            tickBeforeInitialized =
                ((self.tickBitmap(wordPos) & (1 << bitPos)) > 0) &&
                ((tickBefore % self.tickSpacing()) == 0) &&
                (tickBefore < tickAfter);

            if (wordPos < wordPosAfter || (wordPos == wordPosAfter && bitPos <= bitPosAfter)) {
                wordPosLower = wordPos;
                bitPosLower = bitPos;
                wordPosHigher = wordPosAfter;
                bitPosHigher = bitPosAfter;
            } else {
                wordPosLower = wordPosAfter;
                bitPosLower = bitPosAfter;
                wordPosHigher = wordPos;
                bitPosHigher = bitPos;
            }
        }

        // （翻译）遍历 tick 位图，统计穿过的已初始化 tick 数量。
        // （翻译）第一张掩码应当包含较低的那个 tick，以及它左边的所有位。
        uint256 mask = type(uint256).max << bitPosLower;
        while (wordPosLower <= wordPosHigher) {
            // （翻译）如果已经到最后一页 tick 位图，只统计到
            // （翻译）结束 tick 为止。
            if (wordPosLower == wordPosHigher) {
                mask = mask & (type(uint256).max >> (255 - bitPosHigher));
            }

            uint256 masked = self.tickBitmap(wordPosLower) & mask;
            initializedTicksCrossed += countOneBits(masked);
            wordPosLower++;
            // （翻译）重置掩码，下一轮把所有位都考虑进去。
            mask = type(uint256).max;
        }

        if (tickAfterInitialized) {
            initializedTicksCrossed -= 1;
        }

        if (tickBeforeInitialized) {
            initializedTicksCrossed -= 1;
        }

        return initializedTicksCrossed;
    }

    function countOneBits(uint256 x) private pure returns (uint16) {
        uint16 bits = 0;
        while (x != 0) {
            bits++;
            x &= (x - 1);
        }
        return bits;
    }
}
