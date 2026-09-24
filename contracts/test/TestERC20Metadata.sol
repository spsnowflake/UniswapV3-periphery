// SPDX-License-Identifier: UNLICENSED
// （翻译）SPDX 许可证标识：未授予开源许可证（测试或私有代码）
pragma solidity =0.7.6;

import '@openzeppelin/contracts/drafts/ERC20Permit.sol';

contract TestERC20Metadata is ERC20Permit {
    constructor(
        uint256 amountToMint,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, amountToMint);
    }
}
