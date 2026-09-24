// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

/// （翻译）标题：permit 接口
/// （翻译）说明：DAI 和 CHAI 使用的 permit 接口
interface IERC20PermitAllowed {
    /// （翻译）说明：通过持有人签名，授权 spender 花费一些代币
    /// （翻译）开发说明：这是 DAI 和 CHAI 使用的 permit 接口
    /// （翻译）参数 holder：代币持有人地址，也就是代币所有者
    /// （翻译）参数 spender：代币花费者的地址
    /// （翻译）参数 nonce：持有人的 nonce，每次调用 permit 都会增加
    /// （翻译）参数 expiry：permit 失效的时间戳
    /// （翻译）参数 allowed：设置授权额度的布尔值，true 表示 type(uint256).max，false 表示 0
    /// （翻译）参数 v：必须和 r、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 r：必须和 v、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 s：必须和 r、v 一起构成持有人的有效 secp256k1 签名
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
