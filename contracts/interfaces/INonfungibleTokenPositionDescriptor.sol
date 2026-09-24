// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
pragma solidity >=0.5.0;

import './INonfungiblePositionManager.sol';

/// （翻译）标题：用 URI 描述头寸 NFT
interface INonfungibleTokenPositionDescriptor {
    /// （翻译）说明：为某个头寸管理合约上的特定 tokenId 生成描述用 URI
    /// （翻译）开发说明：这个 URI 可能是 data: URI，JSON 内容直接内联在里面
    /// （翻译）参数 positionManager：要描述其代币的头寸管理合约
    /// （翻译）参数 tokenId：要生成描述的代币 ID，这个 ID 可能无效
    /// （翻译）返回：符合 ERC721 的元数据 URI
    function tokenURI(INonfungiblePositionManager positionManager, uint256 tokenId)
        external
        view
        returns (string memory);
}
