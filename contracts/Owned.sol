pragma solidity ^0.6.9;
// SPDX-License-Identifier: MIT

contract Owned {

    address public mOwner;      // AG: should be private
    bool public initialised;    // AG: should be private

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function _initOwned(address _owner) internal {
        require(!initialised);
        mOwner = _owner;
        initialised = true;
        emit OwnershipTransferred(address(0), mOwner);
    }
    function owner() public view returns (address) {
        return mOwner;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == mOwner;
    }
    function transferOwnership(address newOwner) public {
        require(isOwner());
        require(newOwner != address(0));
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(mOwner, newOwner);
        mOwner = newOwner;
    }
}
