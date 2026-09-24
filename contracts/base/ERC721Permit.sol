// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity =0.7.6;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Address.sol';

import '../libraries/ChainId.sol';
import '../interfaces/external/IERC1271.sol';
import '../interfaces/IERC721Permit.sol';
import './BlockTimestamp.sol';

/// （翻译）标题：带 permit 的 ERC721
/// （翻译）说明：支持用签名授权的非同质化代币，也就是 permit
abstract contract ERC721Permit is BlockTimestamp, ERC721, IERC721Permit {
    /// （翻译）开发说明：读取某个 tokenId 当前的 nonce，然后把它加 1，返回加之前的原值
    function _getAndIncrementNonce(uint256 tokenId) internal virtual returns (uint256);

    /// （翻译）开发说明：permit 签名校验里用到的 name 哈希
    bytes32 private immutable nameHash;

    /// （翻译）开发说明：permit 签名校验里用到的 version 字符串哈希
    bytes32 private immutable versionHash;

    /// （翻译）说明：计算 nameHash 和 versionHash
    constructor(
        string memory name_,
        string memory symbol_,
        string memory version_
    ) ERC721(name_, symbol_) {
        nameHash = keccak256(bytes(name_));
        versionHash = keccak256(bytes(version_));
    }

    /// （翻译）IERC721Permit
    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    // （翻译）这是 EIP712Domain(string name,string version,uint256 chainId,address verifyingContract) 的 keccak256
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    nameHash,
                    versionHash,
                    ChainId.get(),
                    address(this)
                )
            );
    }

    /// （翻译）IERC721Permit
    /// （翻译）开发说明：这个值等于 keccak256("Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)")
    bytes32 public constant override PERMIT_TYPEHASH =
        0x49ecf333e5b8c95c40fdafc95c1ad136e8914a8fb55e9dc8bb01eaa83a2df9ad;

    /// （翻译）IERC721Permit
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable override {
        require(_blockTimestamp() <= deadline, 'Permit expired');

        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    '\x19\x01',
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, spender, tokenId, _getAndIncrementNonce(tokenId), deadline))
                )
            );
        address owner = ownerOf(tokenId);
        require(spender != owner, 'ERC721Permit: approval to current owner');

        if (Address.isContract(owner)) {
            require(IERC1271(owner).isValidSignature(digest, abi.encodePacked(r, s, v)) == 0x1626ba7e, 'Unauthorized');
        } else {
            address recoveredAddress = ecrecover(digest, v, r, s);
            require(recoveredAddress != address(0), 'Invalid signature');
            require(recoveredAddress == owner, 'Unauthorized');
        }

        _approve(spender, tokenId);
    }
}
