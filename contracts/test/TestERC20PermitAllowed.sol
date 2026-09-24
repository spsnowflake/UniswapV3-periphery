// SPDX-License-Identifier: UNLICENSED
// （翻译）SPDX 许可证标识：未授予开源许可证（测试或私有代码）
pragma solidity =0.7.6;

import './TestERC20.sol';
import '../interfaces/external/IERC20PermitAllowed.sol';

// （翻译）这里有一个假的 permit，只是用另一种签名类型去授权 type(uint256).max
contract TestERC20PermitAllowed is TestERC20, IERC20PermitAllowed {
    constructor(uint256 amountToMint) TestERC20(amountToMint) {}

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(this.nonces(holder) == nonce, 'TestERC20PermitAllowed::permit: wrong nonce');
        permit(holder, spender, allowed ? type(uint256).max : 0, expiry, v, r, s);
    }
}
