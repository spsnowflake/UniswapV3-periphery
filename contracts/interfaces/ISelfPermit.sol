// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;

/// （翻译）标题：自授权 Self Permit
/// （翻译）说明：对任意符合 EIP-2612 的代币调用 permit，以便在同一条路由里使用
interface ISelfPermit {
    /// （翻译）说明：允许本合约花费 msg.sender 的指定代币
    /// （翻译）开发说明：owner 始终是 msg.sender，spender 始终是 address(this)。
    /// （翻译）参数 token：被花费的代币地址
    /// （翻译）参数 value：该代币允许被花费的数量
    /// （翻译）参数 deadline：一个时间戳，当前区块时间必须小于或等于它
    /// （翻译）参数 v：必须和 r、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 r：必须和 v、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 s：必须和 r、v 一起构成持有人的有效 secp256k1 签名
    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    /// （翻译）说明：允许本合约花费 msg.sender 的指定代币
    /// （翻译）开发说明：owner 始终是 msg.sender，spender 始终是 address(this)。
    /// （翻译）可以用来代替 selfPermit，避免 selfPermit 被抢跑后导致调用失败
    /// （翻译）参数 token：被花费的代币地址
    /// （翻译）参数 value：该代币允许被花费的数量
    /// （翻译）参数 deadline：一个时间戳，当前区块时间必须小于或等于它
    /// （翻译）参数 v：必须和 r、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 r：必须和 v、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 s：必须和 r、v 一起构成持有人的有效 secp256k1 签名
    function selfPermitIfNecessary(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    /// （翻译）说明：对带 allowed 参数的 permit 签名，允许本合约花费发送者的代币
    /// （翻译）开发说明：owner 始终是 msg.sender，spender 始终是 address(this)
    /// （翻译）参数 token：被花费的代币地址
    /// （翻译）参数 nonce：所有者当前的 nonce
    /// （翻译）参数 expiry：permit 失效的时间戳
    /// （翻译）参数 v：必须和 r、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 r：必须和 v、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 s：必须和 r、v 一起构成持有人的有效 secp256k1 签名
    function selfPermitAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    /// （翻译）说明：对带 allowed 参数的 permit 签名，允许本合约花费发送者的代币
    /// （翻译）开发说明：owner 始终是 msg.sender，spender 始终是 address(this)
    /// （翻译）可以用来代替 selfPermitAllowed，避免 selfPermitAllowed 被抢跑后导致调用失败。
    /// （翻译）参数 token：被花费的代币地址
    /// （翻译）参数 nonce：所有者当前的 nonce
    /// （翻译）参数 expiry：permit 失效的时间戳
    /// （翻译）参数 v：必须和 r、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 r：必须和 v、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 s：必须和 r、v 一起构成持有人的有效 secp256k1 签名
    function selfPermitAllowedIfNecessary(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}
