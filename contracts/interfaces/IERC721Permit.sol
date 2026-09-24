// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.7.5;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/// （翻译）标题：带 permit 的 ERC721
/// （翻译）说明：ERC721 的扩展，增加了基于签名授权的 permit 函数
interface IERC721Permit is IERC721 {
    /// （翻译）说明：permit 签名里使用的 typehash
    /// （翻译）返回：permit 的 typehash
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    /// （翻译）说明：permit 签名里使用的域分隔符
    /// （翻译）返回：编码 permit 签名时使用的域分隔符（原文 seperator 是 separator 的拼写错误）
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /// （翻译）说明：通过签名，授权 spender 花费指定的 tokenId
    /// （翻译）参数 spender：被授权的账户
    /// （翻译）参数 tokenId：被授权花费的代币 ID
    /// （翻译）参数 deadline：调用必须在这个时间戳之前被打包，授权才会生效
    /// （翻译）参数 v：必须和 r、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 r：必须和 v、s 一起构成持有人的有效 secp256k1 签名
    /// （翻译）参数 s：必须和 r、v 一起构成持有人的有效 secp256k1 签名
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}
