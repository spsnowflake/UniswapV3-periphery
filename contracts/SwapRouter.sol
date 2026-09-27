// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/libraries/SafeCast.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import './interfaces/ISwapRouter.sol';
import './base/PeripheryImmutableState.sol';
import './base/PeripheryValidation.sol';
import './base/PeripheryPaymentsWithFee.sol';
import './base/Multicall.sol';
import './base/SelfPermit.sol';
import './libraries/Path.sol';
import './libraries/PoolAddress.sol';
import './libraries/CallbackValidation.sol';
import './interfaces/external/IWETH9.sol';

/// （翻译）标题：Uniswap V3 兑换路由器
/// （翻译）说明：对 Uniswap V3 做无状态兑换的路由器
contract SwapRouter is
    ISwapRouter,
    PeripheryImmutableState,
    PeripheryValidation,
    PeripheryPaymentsWithFee,
    Multicall,
    SelfPermit
{
    using Path for bytes;
    using SafeCast for uint256;

    /// （翻译）开发说明：amountInCached 的占位初值。精确输出兑换算出来的输入数量
    /// 永远不可能真的等于这个值（uint256 最大值）。
    uint256 private constant DEFAULT_AMOUNT_IN_CACHED = type(uint256).max;

    /// （翻译）开发说明：临时存储变量，用来返回精确输出兑换计算出的输入数量。
    uint256 private amountInCached = DEFAULT_AMOUNT_IN_CACHED;

    constructor(address _factory, address _WETH9) PeripheryImmutableState(_factory, _WETH9) {}

    /// （翻译）开发说明：根据代币对和手续费档位返回池子。这个池子合约可能存在，也可能还不存在。
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) private view returns (IUniswapV3Pool) {
        return IUniswapV3Pool(PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    /// （翻译）说明：通过 IUniswapV3Pool#swap 执行兑换之后，回调到 msg.sender
    /// （翻译）开发说明：实现里必须把这笔兑换欠池子的代币付清
    /// 必须检查调用者是由官方 UniswapV3Factory 部署出来的 UniswapV3Pool，
    //  如果没有代币被兑换，amount0Delta 和 amount1Delta 都可以是 0
    /// （翻译）参数 amount0Delta：到兑换结束时，池子已经付出（负数）或必须收到（正数）的 token0 数量。
    // 为正时，回调必须把相应数量的 token0 发给池子
    /// （翻译）参数 amount1Delta：到兑换结束时，池子已经付出（负数）或必须收到（正数）的 token1 数量。
    // 为正时，回调必须把相应数量的 token1 发给池子
    /// （翻译）参数 data：调用方通过 IUniswapV3PoolActions#swap 原样传过来的数据
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0);
        // （翻译）完全落在零流动性区间内的兑换不受支持
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
        // 确认回调的的调用者就是 factory 官方池子。
        CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee);

        // 池子回调给出的 delta 里，正数是池子要收的代币，负数是池子已经付出的代币。
        // 正常兑换恰好一侧为正。这里的 require 已经保证至少有一侧大于 0，
        // 所以这里用 amount0Delta > 0 就能分出两种情况：
        // 1.amount0Delta > 0，池子要收 token0。
        // 2.amount1Delta > 0，池子要收 token1。
        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0
                ? (tokenIn < tokenOut, uint256(amount0Delta))
                : (tokenOut < tokenIn, uint256(amount1Delta));
        // isExactInput 用来区分路径是正向编码还是反向编码。精确输入是正向编码，精确输出是反向编码。
        // data.payer 是付款人，一般是发起兑换的用户；多跳中间跳则是路由器自己。
        // msg.sender 是收款人，也就是当前这个池子。
        if (isExactInput) {
            pay(tokenIn, data.payer, msg.sender, amountToPay);
        } else {
            // （翻译）要么发起下一跳兑换，要么在这里付款
            if (data.path.hasMultiplePools()) {
                data.path = data.path.skipToken();
                exactOutputInternal(amountToPay, msg.sender, 0, data);
            } else {
                amountInCached = amountToPay;
            // 精确输出里，回调里叫 tokenIn 的其实是用户要收到的代币，真正要付的是第二个。
                tokenIn = tokenOut;
                // （翻译）精确输出兑换的路径是反的，所以这里把换入和换出代币对调
                pay(tokenIn, data.payer, msg.sender, amountToPay);
            }
        }
    }

    /// （翻译）开发说明：执行单跳精确输入兑换
    function exactInputInternal(
        uint256 amountIn,
        address recipient,
        uint160 sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256 amountOut) {
        // （翻译）接收方传 address(0) 时，表示兑换到路由器自己
        if (recipient == address(0)) recipient = address(this);

        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0, int256 amount1) =
            getPool(tokenIn, tokenOut, fee).swap(
                recipient,
                zeroForOne,
                amountIn.toInt256(),
                sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : sqrtPriceLimitX96,
                abi.encode(data)
            );
        // 池子付代币给用户，所以返回的值是负数，要取绝对值，再加个负号。
        return uint256(-(zeroForOne ? amount1 : amount0));
    }



    /// （翻译）说明：用 amountIn 数量的一种代币，尽可能多地换成另一种代币
    /// （翻译）参数 params：这笔兑换所需参数，在 calldata 里按 ExactInputSingleParams 编码
    /// （翻译）返回 amountOut：收到的代币数量
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint256 amountOut)
    {
        amountOut = exactInputInternal(
            params.amountIn,
            params.recipient,
            params.sqrtPriceLimitX96,
            SwapCallbackData({path: abi.encodePacked(params.tokenIn, params.fee, params.tokenOut), payer: msg.sender})
        );
        require(amountOut >= params.amountOutMinimum, 'Too little received');
    }



    /// （翻译）说明：沿指定路径，用 amountIn 数量的一种代币尽可能多地换成另一种
    /// （翻译）参数 params：这笔多跳兑换所需参数，在 calldata 里按 ExactInputParams 编码
    
    /// （翻译）返回 amountOut：收到的代币数量
    function exactInput(ExactInputParams memory params)
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint256 amountOut)
    {
        address payer = msg.sender;
        // （翻译）第一跳由 msg.sender 付款

        while (true) {
            bool hasMultiplePools = params.path.hasMultiplePools();

            // （翻译）前一跳的输出，变成后一跳的输入
            params.amountIn = exactInputInternal(
                params.amountIn,
                hasMultiplePools ? address(this) : params.recipient,
                // （翻译）中间跳的输出先托管在本合约
                0,
                SwapCallbackData({
                    path: params.path.getFirstPool(),
                    // （翻译）这一跳只需要路径里的第一个池子
                    payer: payer
                })
            );

            // （翻译）决定继续下一跳，还是在这里结束
            if (hasMultiplePools) {
                payer = address(this);
                // （翻译）到这里，调用者已经付过款了
                params.path = params.path.skipToken();
            } else {
                amountOut = params.amountIn;
                break;
            }
        }

        require(amountOut >= params.amountOutMinimum, 'Too little received');
    }

    /// （翻译）开发说明：执行单跳精确输出兑换
    function exactOutputInternal(
        uint256 amountOut,
        address recipient,
        uint160 sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256 amountIn) {
        // （翻译）接收方传 address(0) 时，表示兑换到路由器自己
        if (recipient == address(0)) recipient = address(this);

        (address tokenOut, address tokenIn, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0Delta, int256 amount1Delta) =
            getPool(tokenIn, tokenOut, fee).swap(
                recipient,
                zeroForOne,
                -amountOut.toInt256(),
                sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : sqrtPriceLimitX96,
                abi.encode(data)
            );

        uint256 amountOutReceived;
        (amountIn, amountOutReceived) = zeroForOne
            ? (uint256(amount0Delta), uint256(-amount1Delta))
            : (uint256(amount1Delta), uint256(-amount0Delta));
        // （翻译）技术上有可能拿不到完整的输出数量，
        //  所以如果没有指定价格限制，就要求必须拿到完整输出，排除这种情况
        if (sqrtPriceLimitX96 == 0) require(amountOutReceived == amountOut);
    }

    /// （翻译）说明：为了得到 amountOut 数量的另一种代币，尽可能少地花掉前一种代币
    /// （翻译）参数 params：这笔兑换所需参数，在 calldata 里按 ExactOutputSingleParams 编码
    /// （翻译）返回 amountIn：输入代币的数量
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint256 amountIn)
    {
        // （翻译）直接用 swap 的返回值，少一次 SLOAD
        amountIn = exactOutputInternal(
            params.amountOut,
            params.recipient,
            params.sqrtPriceLimitX96,
            SwapCallbackData({path: abi.encodePacked(params.tokenOut, params.fee, params.tokenIn), payer: msg.sender})
        );

        require(amountIn <= params.amountInMaximum, 'Too much requested');
        // （翻译）单跳用不到这个缓存，但仍然必须把它重置掉
        amountInCached = DEFAULT_AMOUNT_IN_CACHED;
    }

    /// （翻译）说明：沿指定路径（方向是反的）用尽可能少的输入，换到 amountOut 数量的输出
    /// （翻译）参数 params：这笔多跳兑换所需参数，在 calldata 里按 ExactOutputParams 编码
    /// （翻译）返回 amountIn：输入代币的数量
    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint256 amountIn)
    {
        // （翻译）这里把付款人固定成 msg.sender 是可以的，因为他们只为“最后”那一跳精确输出付款
        // （翻译）这一跳会最先发生，后面的跳在嵌套回调里付款
        exactOutputInternal(
            params.amountOut,
            params.recipient,
            0,
            SwapCallbackData({path: params.path, payer: msg.sender})
        );

        amountIn = amountInCached;
        require(amountIn <= params.amountInMaximum, 'Too much requested');
        amountInCached = DEFAULT_AMOUNT_IN_CACHED;
    }
}
