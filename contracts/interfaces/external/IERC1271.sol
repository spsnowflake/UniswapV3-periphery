// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

/// （翻译）标题：校验合约账户签名的接口
/// （翻译）说明：校验给定数据所提供签名的接口
/// （翻译）开发说明：EIP-1271 定义的接口
interface IERC1271 {
    /// （翻译）说明：返回所提供的签名对所提供的数据是否有效
    /// （翻译）开发说明：函数校验通过时必须返回 bytes4 魔数 0x1626ba7e。
    /// （翻译）不得修改状态（solc 0.5 之前用 STATICCALL，之后用 view）。
    /// （翻译）必须允许外部调用。
    /// （翻译）参数 hash：待签名数据的哈希
    /// （翻译）参数 signature：与数据关联的签名字节数组
    /// （翻译）返回 magicValue：bytes4 魔数 0x1626ba7e
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
