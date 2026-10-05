// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/IMulticall.sol';

/// （翻译）标题：Multicall
/// （翻译）说明：允许在一次合约调用里执行多个方法
abstract contract Multicall is IMulticall {
    /// （翻译）IMulticall
    function multicall(bytes[] calldata data) public payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

// 把子调用失败时的原始报错原样抛出去。
            if (!success) {
                // 带字符串的 require 或 revert("...") 返回的数据是：4 字节的 Error(string) 选择器，
                // 后面才是按 ABI 编码的错误字符串。68 字节能放下选择器、字符串偏移和字符串长度。
                // 短于 68 说明没有错误字符串（空的 revert()），于是直接 revert()。

                // （翻译）下面 5 行来自 https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();

                // 够长时，assembly 把指针向前移 4 字节，跳过选择器，再用 abi.decode 解出字符串，
                // 例如 'STF'、'Price slippage check'。最后的 revert(那个字符串) 让整笔 multicall 以同一句错误失败，
                // 而不是只返回一个笼统的调用失败。
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }
// 成功的那次则把返回值放进 results[i]，继续下一笔。
            results[i] = result;
        }
    }
}
