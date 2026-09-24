// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

/// （翻译）标题：根据工厂、代币和手续费推导池子地址的函数
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    /// （翻译）说明：标识一个池子的键
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// （翻译）说明：返回 PoolKey：排好序的代币，以及对应的手续费档位
    /// （翻译）参数 tokenA：池子的第一个代币，尚未排序
    /// （翻译）参数 tokenB：池子的第二个代币，尚未排序
    /// （翻译）参数 fee：池子的手续费档位

    /// （翻译）返回 PoolKey：排好 token0 和 token1 之后的池子信息
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    /// （翻译）说明：根据工厂和 PoolKey 确定性算出池子地址
    /// （翻译）参数 factory：Uniswap V3 工厂合约地址
    /// （翻译）参数 key：池子键 PoolKey
    
    /// （翻译）返回 pool：V3 池子的合约地址
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}
