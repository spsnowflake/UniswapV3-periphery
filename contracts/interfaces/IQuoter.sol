// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

/// （翻译）标题：报价器接口
/// （翻译）说明：支持对精确输入或精确输出兑换的计算结果做报价
/// （翻译）开发说明：这些函数没有标成 view，因为它们靠调用非 view 函数然后 revert
/// （翻译）来算出结果。它们也不省 gas，不应当在链上调用。
interface IQuoter {
    /// （翻译）说明：对一笔给定的精确输入兑换，返回能收到的输出数量，但不真正执行兑换
    /// （翻译）参数 path：兑换路径，也就是每一对代币和对应池子的手续费
    /// （翻译）参数 amountIn：要换出的第一种代币的数量
    /// （翻译）返回 amountOut：将会收到的最后一种代币的数量
    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);

    /// （翻译）说明：对单个池子的精确输入兑换，返回能收到的输出数量
    /// （翻译）参数 tokenIn：换入的代币
    /// （翻译）参数 tokenOut：换出的代币
    /// （翻译）参数 fee：这一对代币要使用的池子手续费
    /// （翻译）参数 amountIn：希望投入的数量
    /// （翻译）参数 sqrtPriceLimitX96：兑换不能越过的池子价格限制
    /// （翻译）返回 amountOut：将会收到的 tokenOut 数量
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);

    /// （翻译）说明：对一笔给定的精确输出兑换，返回需要的输入数量，但不真正执行兑换
    /// （翻译）参数 path：兑换路径，即每一对代币和池子手续费。路径必须按相反顺序提供
    /// （翻译）参数 amountOut：要收到的最后一种代币的数量
    /// （翻译）返回 amountIn：需要支付的第一种代币的数量
    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);

    /// （翻译）说明：对单个池子，返回为了收到指定精确输出所需的输入数量
    /// （翻译）参数 tokenIn：换入的代币
    /// （翻译）参数 tokenOut：换出的代币
    /// （翻译）参数 fee：这一对代币要使用的池子手续费
    /// （翻译）参数 amountOut：希望得到的输出数量
    /// （翻译）参数 sqrtPriceLimitX96：兑换不能越过的池子价格限制
    /// （翻译）返回 amountIn：为了收到 amountOut，兑换所需的输入数量
    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);
}
