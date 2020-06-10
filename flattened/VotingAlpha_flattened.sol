pragma solidity ^0.6.9;

// SPDX-License-Identifier: MIT


library Members {
    struct Member {
        bool exists;
        uint index;
        string name;
    }
    struct Data {
        bool initialised;
        mapping(address => Member) entries;
        address[] index;
    }

    event MemberAdded(address indexed _address, string  _name,  uint totalAfter);
    event MemberRemoved(address indexed _address, string  _name, uint totalAfter);
    event MemberNameUpdated(address indexed memberAddress, string oldName, string newName);

    function init(Data storage self) public {
        require(!self.initialised);
        self.initialised = true;
    }
    function isInitialised(Data storage self) public view returns (bool) {
        return self.initialised;
    }
    function isMember(Data storage self, address _address) public view returns (bool) {
        return self.entries[_address].exists;
    }

    function add(Data storage self, address _address, string memory _name) public {
        require(!self.entries[_address].exists);
        self.index.push(_address);
        self.entries[_address] = Member(true, self.index.length - 1, _name);
        emit MemberAdded(_address, _name, self.index.length);
    }
    function remove(Data storage self, address _address) public {
        require(self.entries[_address].exists);
        uint removeIndex = self.entries[_address].index;
        emit MemberRemoved(_address, self.entries[_address].name, self.index.length - 1);
        uint lastIndex = self.index.length - 1;
        address lastIndexAddress = self.index[lastIndex];
        self.index[removeIndex] = lastIndexAddress;
        self.entries[lastIndexAddress].index = removeIndex;
        delete self.entries[_address];
        if (self.index.length > 0) {
            self.index.pop();
        }
    }
    function setName(Data storage self, address memberAddress, string memory _name) public {
        Member storage member = self.entries[memberAddress];
        require(member.exists);
        emit MemberNameUpdated(memberAddress, member.name, _name);
        member.name = _name;
    }
    function length(Data storage self) public view returns (uint) {
        return self.index.length;
    }
}


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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// ----------------------------------------------------------------------------
// Voting Proposals
//
// URL: ClubEth.App
// GitHub: https://github.com/bokkypoobah/ClubEth
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd and
// the ClubEth.App Project - 2018. The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Proposals Data Structure
// ----------------------------------------------------------------------------

library Proposals {
    enum ProposalType {
        NationalBill,                         //  0 NationalBill
        StateBill                             //  1 StateBill
    }

    struct Proposal {
        ProposalType proposalType;
        address proposer;
        string  description;
        mapping(address => uint) voted;
        uint votedNo;
        uint votedYes;
        uint initiated;
        uint closed;
        bool pass;
    }

    struct Data {
        bool initialised;
        Proposal[] proposals;
    }

    event NewProposal(uint indexed proposalId, Proposals.ProposalType indexed proposalType, address indexed proposer); 
    event Voted(uint indexed proposalId, address indexed voter, bool vote, uint votedYes, uint votedNo);

    function proposeNationalBill(Data storage self, string memory billName) internal returns (uint proposalId) {
        Proposal memory proposal = Proposal({
            proposalType: ProposalType.NationalBill,
            proposer: msg.sender,
            description: billName,
            votedNo: 0,
            votedYes: 0,
            initiated: now,
            closed: 0,
            pass: false
        });
        self.proposals.push(proposal);
        proposalId = self.proposals.length - 1;
        emit NewProposal(proposalId, proposal.proposalType, msg.sender);
    }


    function vote(Data storage self, uint proposalId, bool yesNo) internal {
        Proposal storage proposal = self.proposals[proposalId];
        require(proposal.closed == 0);
        // First vote
        if (proposal.voted[msg.sender] == 0) {
            if (yesNo) {
                proposal.votedYes++;
                proposal.voted[msg.sender] = 1;
            } else {
                proposal.votedNo++;
                proposal.voted[msg.sender] = 2;
            }
            emit Voted(proposalId, msg.sender, yesNo, proposal.votedYes, proposal.votedNo);
        // Changing Yes to No
        } else if (proposal.voted[msg.sender] == 1 && !yesNo && proposal.votedYes > 0) {
            proposal.votedYes--;
            proposal.votedNo++;
            proposal.voted[msg.sender] = 2;
            emit Voted(proposalId, msg.sender, yesNo, proposal.votedYes, proposal.votedNo);
        // Changing No to Yes
        } else if (proposal.voted[msg.sender] == 2 && yesNo && proposal.votedNo > 0) {
            proposal.votedYes++;
            proposal.votedNo--;
            proposal.voted[msg.sender] = 1;
            emit Voted(proposalId, msg.sender, yesNo, proposal.votedYes, proposal.votedNo);
        }


    }

    function getVotingStatus(Data storage self, uint proposalId) internal view returns (bool isOpen, uint voteCount, uint yesPercent,uint noPercent) {
        Proposal storage proposal = self.proposals[proposalId];
        isOpen = (proposal.closed == 0);
        voteCount = proposal.votedYes + proposal.votedNo;
        yesPercent = proposal.votedYes * 100 / voteCount;
        noPercent = proposal.votedNo * 100 / voteCount;
    }
    // function get(Data storage self, uint proposalId) public view returns (Proposal proposal) {
    //    return self.proposals[proposalId];
    // }
    function getProposalType(Data storage self, uint proposalId) internal view returns (ProposalType) {
        return self.proposals[proposalId].proposalType;
    }
    function getDescription(Data storage self, uint proposalId) internal view returns (string memory) {
        return self.proposals[proposalId].description;
    }
    function getInitiated(Data storage self, uint proposalId) internal view returns (uint) {
        return self.proposals[proposalId].initiated;
    }
    function isClosed(Data storage self, uint proposalId) internal view returns (bool) {
        self.proposals[proposalId].closed;
    }
    function pass(Data storage self, uint proposalId) internal view returns (bool) {
        return self.proposals[proposalId].pass;
    }
    function toExecute(Data storage self, uint proposalId) internal view returns (bool) {
        return self.proposals[proposalId].pass && self.proposals[proposalId].closed == 0;
    }
    function close(Data storage self, uint proposalId) internal {
        self.proposals[proposalId].closed = now;
    }
    function length(Data storage self) internal view returns (uint) {
        return self.proposals.length;
    }
}


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


// ----------------------------------------------------------------------------
//
// Voting Alpha - MVP for DigiPol Australia
//
//
// From Decentralised Future Fund DAO
// https://github.com/bokkypoobah/DecentralisedFutureFundDAO
//
// (c) Adrian Guerrera  / Deepyt Pty Ltd 2020. The MIT Licence.
// ----------------------------------------------------------------------------


contract VotingAlpha is Operated {
    using SafeMath for uint;
    using Members for Members.Data;
    using Proposals for Proposals.Data;


    Members.Data members;
    Proposals.Data proposals;

    // Must be copied here to be added to the ABI
    event MemberAdded(address indexed memberAddress, string name, uint totalAfter);
    event MemberRemoved(address indexed memberAddress, string name, uint totalAfter);
    event MemberNameUpdated(address indexed memberAddress, string oldName, string newName);

    event NewProposal(uint indexed proposalId, Proposals.ProposalType indexed proposalType, address indexed proposer); 
    event Voted(uint indexed proposalId, address indexed voter, bool vote, uint votedYes, uint votedNo);


    // ----------------------------------------------------------------------------
    /// @dev Initialisation functions
    // ----------------------------------------------------------------------------

    /// @dev Run this first to set the contract owner. 
    function initVotingAlpha() public {
        require(!members.isInitialised());
        _initOperated(msg.sender);
    }

    function initAddMember( string memory _name, address _address) public  {
        require(isOwner());
        members.add(_address, _name);
    }

    /// @dev Add operators so that they can add members later. 
    function initAddOperator( address _operator) public  {
        require(isOwner());
        addOperator(_operator);
    }

    function initRemoveMember(address _address) public {
        require(isOwner());
        require(!members.isInitialised());
        members.remove(_address);
    }

    /// @dev Once you have created the contract and added operators and members.
    /// @dev Then you can finalise it. Once you do, you can no longer add operators.
    function initComplete() public {
        require(isOwner());
        require(!members.isInitialised());
        require(members.length() != 0);
        members.init();
        _transferOwnership(address(0));
    }


    // ----------------------------------------------------------------------------
    /// @dev Proposals
    // ----------------------------------------------------------------------------
    
    /// @dev Operator adds new bill to be voted on
    function proposeNationalBill(string memory billName) public  returns (uint proposalId) {
        require(operators[msg.sender]);
        proposalId = proposals.proposeNationalBill(billName);
    }

    /// @dev Members vote on proposals
    function voteNo(uint proposalId) public {
        require(members.isMember(msg.sender));
        vote(proposalId, false);
    }
    function voteYes(uint proposalId) public {
        require(members.isMember(msg.sender));
        vote(proposalId, true);
    }

    /// @dev internals to handle both yes and no votes
    function vote(uint proposalId, bool yesNo) internal {
        proposals.vote(proposalId, yesNo);
        Proposals.ProposalType proposalType = proposals.getProposalType(proposalId);
        if (proposals.toExecute(proposalId)) {
            proposals.close(proposalId);
        }
    }


    // ----------------------------------------------------------------------------
    /// @dev Members
    // ----------------------------------------------------------------------------
    
    function addMember(address memberAddress, string memory memberName) internal {
        members.add(memberAddress, memberName);
    }
    function removeMember(address memberAddress) internal {
        members.remove(memberAddress);
    }

    function operatorAddMember( string memory _name, address _address) public  {
        require(operators[msg.sender]);
        members.add(_address, _name);
    }
    function operatorRemoveMember(address _address) public {
        require(operators[msg.sender]);
        require(!members.isInitialised());
        members.remove(_address);
    }

    // ----------------------------------------------------------------------------
    /// @dev Getter functions
    // ----------------------------------------------------------------------------

    /// @dev Details for a given proposal ID
    function getProposal(uint proposalId) public view returns (uint _proposalType, address _proposer, string memory _description, uint _votedNo, uint _votedYes, uint _initiated, uint _closed) {
        Proposals.Proposal memory proposal = proposals.proposals[proposalId];
        _proposalType = uint(proposal.proposalType);
        _proposer = proposal.proposer;
        _description = proposal.description;
        _votedNo = proposal.votedNo;
        _votedYes = proposal.votedYes;
        _initiated = proposal.initiated;
        _closed = proposal.closed;
    }
    /// @dev Results for a given proposal ID
    function getVotingStatus(uint proposalId) public view returns ( bool isOpen, uint voteCount, uint yesPercent, uint noPercent) {
        return proposals.getVotingStatus(proposalId);
    }

    function numberOfProposals() public view returns (uint) {
        return proposals.length();
    }
    function numberOfMembers() public view returns (uint) {
        return members.length();
    }

    /// @dev Returns an array of the registered members
    function getMembers() public view returns (address[] memory) {
        return members.index;
    }
    function getMemberByIndex(uint _index) public view returns (address _member) {
        return members.index[_index];
    }
    function getMemberData(address memberAddress) public view returns (bool _exists, uint _index, string memory _name) {
        Members.Member memory member = members.entries[memberAddress];
        return (member.exists, member.index, member.name);
    }

}
