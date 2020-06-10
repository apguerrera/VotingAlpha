pragma solidity ^0.6.9;
// SPDX-License-Identifier: MIT

import "./Owned.sol";

contract Operated is Owned {
    mapping(address => bool) public operators;
    bool private mIsOperated;

    event OperatorAdded(address _operator);
    event OperatorRemoved(address _operator);

    modifier onlyOperator() {
        require(operators[msg.sender] || isOwner());
        _;
    }

    function _initOperated(address _owner) internal {
        _initOwned(_owner);
        operators[_owner] = true;
        mIsOperated = true;
    }

    function addOperator(address _operator) public   {
        require(isOwner());
        require(!operators[_operator]);
        operators[_operator] = true;
        emit OperatorAdded(_operator);
    }

    function removeOperator(address _operator) public  {
        require(isOwner());
        require(operators[_operator]);
        delete operators[_operator];
        emit OperatorRemoved(_operator);
    }
    
    function isOperator() public view returns (bool) {
        if (mIsOperated) {
            return operators[msg.sender];
        }
        return false;
    }
    function isOperated() public virtual view returns (bool) {
        return mIsOperated;
    }
    function setOperated(bool _isOperated) public  {
        require(isOwner());
        mIsOperated = _isOperated;
    }
}
