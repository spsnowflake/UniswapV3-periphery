// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

/// （翻译）标题：QuoterV2 接口
/// （翻译）说明：支持对精确输入或精确输出兑换的计算结果做报价。
/// （翻译）说明：对路径中每个池子，还会告诉你穿过了多少个已初始化 tick，以及兑换后池子的平方根价格。
/// （翻译）开发说明：这些函数没有标成 view，因为它们靠调用非 view 函数然后 revert
/// （翻译）来算出结果。它们也不省 gas，不应当在链上调用。
interface IQuoterV2 {
    /// （翻译）说明：对一笔给定的精确输入兑换，返回能收到的输出数量，但不真正执行兑换
    /// （翻译）参数 path：兑换路径，也就是每一对代币和对应池子的手续费
    /// （翻译）参数 amountIn：要换出的第一种代币的数量
    /// （翻译）返回 amountOut：将会收到的最后一种代币的数量
    /// （翻译）返回 sqrtPriceX96AfterList：路径中每个池子兑换后的平方根价格列表
    /// （翻译）返回 initializedTicksCrossedList：路径中每个池子穿过的已初始化 tick 数量列表
    /// （翻译）返回 gasEstimate：这笔兑换消耗 gas 的估计值
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// （翻译）说明：对单个池子的精确输入兑换，返回能收到的输出数量
    /// （翻译）参数 params：报价参数，按 QuoteExactInputSingleParams 编码
    /// （翻译）tokenIn：换入的代币
    /// （翻译）tokenOut：换出的代币
    /// （翻译）fee：这一对代币要使用的池子手续费
    /// （翻译）amountIn：希望投入的数量
    /// （翻译）sqrtPriceLimitX96：兑换不能越过的池子价格限制
    /// （翻译）返回 amountOut：将会收到的 tokenOut 数量
    /// （翻译）返回 sqrtPriceX96After：兑换后池子的平方根价格
    /// （翻译）返回 initializedTicksCrossed：这笔兑换穿过的已初始化 tick 数量
    /// （翻译）返回 gasEstimate：这笔兑换消耗 gas 的估计值
    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );

    /// （翻译）说明：对一笔给定的精确输出兑换，返回需要的输入数量，但不真正执行兑换
    /// （翻译）参数 path：兑换路径，即每一对代币和池子手续费。路径必须按相反顺序提供
    /// （翻译）参数 amountOut：要收到的最后一种代币的数量
    /// （翻译）返回 amountIn：需要支付的第一种代币的数量
    /// （翻译）返回 sqrtPriceX96AfterList：路径中每个池子兑换后的平方根价格列表
    /// （翻译）返回 initializedTicksCrossedList：路径中每个池子穿过的已初始化 tick 数量列表
    /// （翻译）返回 gasEstimate：这笔兑换消耗 gas 的估计值
    function quoteExactOutput(bytes memory path, uint256 amountOut)
        external
        returns (
            uint256 amountIn,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// （翻译）说明：对单个池子，返回为了收到指定精确输出所需的输入数量
    /// （翻译）参数 params：报价参数，按 QuoteExactOutputSingleParams 编码
    /// （翻译）tokenIn：换入的代币
    /// （翻译）tokenOut：换出的代币
    /// （翻译）fee：这一对代币要使用的池子手续费
    /// （翻译）amountOut：希望得到的输出数量
    /// （翻译）sqrtPriceLimitX96：兑换不能越过的池子价格限制
    /// （翻译）返回 amountIn：为了收到 amountOut，兑换所需的输入数量
    /// （翻译）返回 sqrtPriceX96After：兑换后池子的平方根价格
    /// （翻译）返回 initializedTicksCrossed：这笔兑换穿过的已初始化 tick 数量
    /// （翻译）返回 gasEstimate：这笔兑换消耗 gas 的估计值
    function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
        external
        returns (
            uint256 amountIn,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}
