// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import './PoolAddress.sol';

/// （翻译）说明：校验来自 Uniswap V3 池子的回调
library CallbackValidation {
    /// （翻译）说明：返回一个合法的 Uniswap V3 池子地址
    /// （翻译）参数 factory：Uniswap V3 工厂的合约地址
    /// （翻译）参数 tokenA：token0 或 token1 其中一个的合约地址
    /// （翻译）参数 tokenB：另一个代币的合约地址
    /// （翻译）参数 fee：池子每次兑换收取的手续费，单位是 bip 的百分之一（百万分之一，3000 表示 0.3%）

    /// （翻译）返回 pool：V3 池子合约地址
    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {
        return verifyCallback(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    /// （翻译）说明：返回一个合法的 Uniswap V3 池子地址
    /// （翻译）参数 factory：Uniswap V3 工厂的合约地址
    /// （翻译）参数 poolKey：V3 池子的标识键
    
    /// （翻译）返回 pool：V3 池子合约地址
    function verifyCallback(address factory, PoolAddress.PoolKey memory poolKey)
        internal
        view
        returns (IUniswapV3Pool pool)
    {
        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}
