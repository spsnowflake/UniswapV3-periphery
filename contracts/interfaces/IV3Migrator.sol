// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

import './IMulticall.sol';
import './ISelfPermit.sol';
import './IPoolInitializer.sol';

/// （翻译）标题：V3 迁移器
/// （翻译）说明：把兼容 Uniswap V2 的交易对流动性迁移进 Uniswap V3 池子（原文 liqudity 是 liquidity 的拼写错误）
interface IV3Migrator is IMulticall, ISelfPermit, IPoolInitializer {
    struct MigrateParams {
        address pair;
        // （翻译）兼容 Uniswap V2 的交易对合约
        uint256 liquidityToMigrate;
        // （翻译）预期等于调用者持有的 LP 数量 balanceOf(msg.sender)
        uint8 percentageToMigrate;
        // （翻译）用分子表示百分比，分母是 100
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Min;
        // （翻译）必须按 percentageToMigrate 的比例把预期数量打折
        uint256 amount1Min;
        // （翻译）必须按 percentageToMigrate 的比例把预期数量打折
        address recipient;
        uint256 deadline;
        bool refundAsETH;
    }

    /// （翻译）说明：销毁 V2 流动性并铸造一个新的 V3 头寸，从而把流动性迁到 V3
    /// （翻译）开发说明：滑点保护靠 amount0Min 和 amount1Min。它们应当是预期值打过折之后的数量，预期值来自
    /// （翻译）这笔 V2 流动性在 V3 里最多能换成的数量。如果是迁移到一个
    /// （翻译）价格区间之外的头寸，可以把 amount0Min 和 amount1Min 设成 0，从而强制头寸保持在区间外
    /// （翻译）参数 params：迁移 V2 流动性所需的参数，在 calldata 里按 MigrateParams 编码
    function migrate(MigrateParams calldata params) external;
}
