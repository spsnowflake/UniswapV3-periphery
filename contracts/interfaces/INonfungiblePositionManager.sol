// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol';

import './IPoolInitializer.sol';
import './IERC721Permit.sol';
import './IPeripheryPayments.sol';
import './IPeripheryImmutableState.sol';

/// （翻译）标题：头寸的非同质化代币
/// （翻译）说明：把 Uniswap V3 头寸包装成非同质化代币接口，使它们可以被转移
/// （翻译）以及被授权。
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{
    /// （翻译）说明：头寸 NFT 的流动性增加时发出
    /// （翻译）开发说明：铸造代币时也会发出
    /// （翻译）参数 tokenId：流动性被增加的那枚代币的 ID
    /// （翻译）参数 liquidity：该 NFT 头寸增加的流动性数量
    /// （翻译）参数 amount0：为增加流动性支付的 token0 数量
    /// （翻译）参数 amount1：为增加流动性支付的 token1 数量
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    /// （翻译）说明：头寸 NFT 的流动性减少时发出
    /// （翻译）参数 tokenId：流动性被减少的那枚代币的 ID
    /// （翻译）参数 liquidity：该 NFT 头寸减少的流动性数量
    /// （翻译）参数 amount0：因流动性减少而记到账上的 token0 数量
    /// （翻译）参数 amount1：因流动性减少而记到账上的 token1 数量
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    /// （翻译）说明：为头寸 NFT 领取代币时发出
    /// （翻译）开发说明：由于取整，事件里报告的数量可能和实际转出的数量不完全相等
    /// （翻译）参数 tokenId：领取了底层代币的那枚代币的 ID
    /// （翻译）参数 recipient：收到所领取代币的账户地址
    /// （翻译）参数 amount0：从头寸应付额里领走的 token0 数量
    /// （翻译）参数 amount1：从头寸应付额里领走的 token1 数量
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    /// （翻译）说明：返回给定 tokenId 对应的头寸信息。
    /// （翻译）开发说明：如果 tokenId 无效就抛出错误。
    /// （翻译）参数 tokenId：代表该头寸的代币 ID
    /// （翻译）返回 nonce：permit 用的 nonce
    /// （翻译）返回 operator：被授权可以花费这枚 NFT 的地址
    /// （翻译）返回 token0：该池子的 token0 地址
    /// （翻译）返回 token1：该池子的 token1 地址
    /// （翻译）返回 fee：该池子对应的手续费
    /// （翻译）返回 tickLower：头寸 tick 区间的下端
    /// （翻译）返回 tickUpper：头寸 tick 区间的上端
    /// （翻译）返回 liquidity：头寸的流动性
    /// （翻译）返回 feeGrowthInside0LastX128：上次操作这个单独头寸时 token0 的手续费增长
    /// （翻译）返回 feeGrowthInside1LastX128：上次操作这个单独头寸时 token1 的手续费增长
    /// （翻译）返回 tokensOwed0：截至上次计算，头寸尚未领取的 token0
    /// （翻译）返回 tokensOwed1：截至上次计算，头寸尚未领取的 token1
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    /// （翻译）说明：创建一个包在 NFT 里的新头寸
    /// （翻译）开发说明：在池子已经存在并且已经初始化时调用。注意：如果池子已创建但未初始化，
    /// （翻译）并没有单独处理这种情况的方法，也就是默认池子已经初始化。
    /// （翻译）参数 params：铸造头寸所需参数，在 calldata 里按 MintParams 编码
    /// （翻译）返回 tokenId：代表所铸造头寸的代币 ID
    /// （翻译）返回 liquidity：这个头寸的流动性数量
    /// （翻译）返回 amount0：token0 的数量
    /// （翻译）返回 amount1：token1 的数量
    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// （翻译）说明：增加头寸里的流动性，代币由 msg.sender 支付
    /// （翻译）参数 params.tokenId：正在增加流动性的代币 ID，
    /// （翻译）amount0Desired：希望花费的 token0 数量，
    /// （翻译）amount1Desired：希望花费的 token1 数量，
    /// （翻译）amount0Min：至少要花费的 token0，用作滑点检查，
    /// （翻译）amount1Min：至少要花费的 token1，用作滑点检查，
    /// （翻译）deadline：交易必须在这个时间之前被打包，变更才会生效
    /// （翻译）返回 liquidity：增加之后新得到的流动性数量
    /// （翻译）返回 amount0：为达到结果流动性实际用掉的 token0（原文 acheive 是 achieve 的拼写错误）
    /// （翻译）返回 amount1：为达到结果流动性实际用掉的 token1（原文 acheive 是 achieve 的拼写错误）
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// （翻译）说明：减少头寸里的流动性，并把对应代币记到该头寸账上
    /// （翻译）参数 params.tokenId：正在减少流动性的代币 ID，
    /// （翻译）amount：流动性将要减少的数量，
    /// （翻译）amount0Min：烧掉这些流动性后，至少应记到账上的 token0，
    /// （翻译）amount1Min：烧掉这些流动性后，至少应记到账上的 token1，
    /// （翻译）deadline：交易必须在这个时间之前被打包，变更才会生效
    /// （翻译）返回 amount0：记到该头寸应付代币里的 token0 数量
    /// （翻译）返回 amount1：记到该头寸应付代币里的 token1 数量
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    /// （翻译）说明：把某个头寸应付的手续费领取给接收方，最多领到指定上限
    /// （翻译）参数 params.tokenId：正在领取代币的 NFT 的 ID，
    /// （翻译）recipient：应当收到这些代币的账户，
    /// （翻译）amount0Max：最多领取的 token0 数量，
    /// （翻译）amount1Max：最多领取的 token1 数量
    /// （翻译）返回 amount0：以 token0 计、实际领到的手续费
    /// （翻译）返回 amount1：以 token1 计、实际领到的手续费
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    /// （翻译）说明：销毁一个 tokenId，把它从 NFT 合约里删掉。该代币流动性必须为 0，并且所有代币
    /// （翻译）必须先领完。
    /// （翻译）参数 tokenId：正在被销毁的代币 ID
    function burn(uint256 tokenId) external payable;
}
