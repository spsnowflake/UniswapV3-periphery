// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// （翻译）标题：路由器的代币兑换功能
/// （翻译）说明：通过 Uniswap V3 兑换代币的函数
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// （翻译）说明：用 amountIn 数量的一种代币，尽可能多地换成另一种代币
    /// （翻译）参数 params：这笔兑换所需参数，在 calldata 里按 ExactInputSingleParams 编码
    /// （翻译）返回 amountOut：收到的代币数量
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// （翻译）说明：沿指定路径，用 amountIn 数量的一种代币尽可能多地换成另一种
    /// （翻译）参数 params：这笔多跳兑换所需参数，在 calldata 里按 ExactInputParams 编码
    /// （翻译）返回 amountOut：收到的代币数量
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// （翻译）说明：为了得到 amountOut 数量的另一种代币，尽可能少地花掉前一种代币
    /// （翻译）参数 params：这笔兑换所需参数，在 calldata 里按 ExactOutputSingleParams 编码
    /// （翻译）返回 amountIn：输入代币的数量
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// （翻译）说明：沿指定路径（方向是反的）用尽可能少的输入，换到 amountOut 数量的输出
    /// （翻译）参数 params：这笔多跳兑换所需参数，在 calldata 里按 ExactOutputParams 编码
    /// （翻译）返回 amountIn：输入代币的数量
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
