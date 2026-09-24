// SPDX-License-Identifier: GPL-2.0-or-later
// （翻译）SPDX 许可证标识：GPL-2.0 或更高版本
// （翻译）标题：Solidity 字节数组工具
// （翻译）作者：Gonçalo Sá <goncalo.sa@consensys.net>
// （翻译）开发说明：为以太坊 Solidity 合约提供的紧凑打包字节数组工具库。
// （翻译）这个库可以拼接、切片，以及在内存和存储中对字节数组做类型转换。
pragma solidity >=0.5.0 <0.8.0;

library BytesLib {
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    // （翻译）找一块空闲内存，把它的位置存进 tempBytes，做法和
                    // （翻译）Solidity 为内存变量分配空间时一样。
                    tempBytes := mload(0x40)

                    // （翻译）切片结果的第一个字可能是一个不完整的从原数组读出的字。为了读它，我们先算出这个不完整字的长度，
                    // 然后先复制这么多字节到新数组。我们复制的第一个字开头会是我们不关心的数据，但最后 lengthmod 个字节会
                    // 落在新数组内容的开头。当复制完成后，我们用切片的真实长度覆盖整个第一个字。
                    let lengthmod := and(_length, 31)

                    // （翻译）下一行的乘法是必要的因为当切片长度是 32 字节的整数倍时（lengthmod == 0）
                    // 后面的复制循环会把原数组的长度也复制进去然后提前结束，该复制的内容没有复制完。
                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        // （翻译）下一行的乘法和上面那次乘法目的完全一样就是为了避开这个问题。
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    // （翻译）更新空闲内存指针像编译器现在做的那样，把数组按 32 字节对齐分配
                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                // （翻译）如果想要长度为 0 的切片，就直接返回一个长度为 0 的数组
                default {
                    tempBytes := mload(0x40)
                    // （翻译）把即将返回的这 32 字节切片清零必须这样做，因为 Solidity 不会做垃圾回收
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}
