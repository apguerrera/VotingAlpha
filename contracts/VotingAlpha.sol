pragma solidity ^0.5.4;

// import "./Members.sol";
// import "./Proposals.sol";
import "./Operated.sol";
import "./SafeMath.sol";


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
// SPDX-License-Identifier: MIT


library MembersInternal {
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

    function init(Data storage self) internal {
        require(!self.initialised);
        self.initialised = true;
    }
    function isInitialised(Data storage self) internal view returns (bool) {
        return self.initialised;
    }
    function isMember(Data storage self, address _address) internal view returns (bool) {
        return self.entries[_address].exists;
    }

    function add(Data storage self, address _address, string memory _name) internal {
        require(!self.entries[_address].exists);
        self.index.push(_address);
        self.entries[_address] = Member(true, self.index.length - 1, _name);
        emit MemberAdded(_address, _name, self.index.length);
    }
    function remove(Data storage self, address _address) internal {
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
    function setName(Data storage self, address memberAddress, string memory _name) internal {
        Member storage member = self.entries[memberAddress];
        require(member.exists);
        emit MemberNameUpdated(memberAddress, member.name, _name);
        member.name = _name;
    }
    function length(Data storage self) internal view returns (uint) {
        return self.index.length;
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
// SPDX-License-Identifier: MIT

// ----------------------------------------------------------------------------
// Proposals Data Structure
// ----------------------------------------------------------------------------

library ProposalsInternal {
    enum ProposalType {
        NationalBill,                         //  0 NationalBill
        StateBill                             //  1 StateBill
    }

    struct Proposal {
        ProposalType proposalType;
        address proposer;
        bytes32  specHash;
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
        mapping(bytes32 => uint256) specHashToId;
    }

    event NewProposal(uint indexed proposalId, bytes32 specHash, ProposalsInternal.ProposalType indexed proposalType, address indexed proposer);
    event Voted(uint indexed proposalId, address indexed voter, bool vote, uint votedYes, uint votedNo);

    function proposeNationalBill(Data storage self, bytes32 _specHash) internal returns (uint proposalId) {
        Proposal memory proposal = Proposal({
            proposalType: ProposalType.NationalBill,
            proposer: msg.sender,
            specHash: _specHash,
            votedNo: 0,
            votedYes: 0,
            initiated: now,
            closed: 0,
            pass: false
        });
        self.proposals.push(proposal);
        proposalId = self.proposals.length - 1;
        self.specHashToId[_specHash] = proposalId;
        emit NewProposal(proposalId, _specHash, proposal.proposalType, msg.sender);
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

    function getVotingStatus(Data storage self, uint proposalId) internal view returns (bool isOpen, uint voteCount, uint yesPercent,uint noPercent, uint nVotes, uint nYes, uint nNo) {
        Proposal storage proposal = self.proposals[proposalId];
        isOpen = (proposal.closed == 0);
        // TODO: I suggest this is done _outside_ the client; otherwise you really should be multiplying by a larger number (or just shift left 30 bits since they're uints. 30 bits ~= 10^9)
        voteCount = proposal.votedYes + proposal.votedNo;
        yesPercent = proposal.votedYes * 100 / voteCount;
        noPercent = proposal.votedNo * 100 / voteCount;
        nVotes = voteCount;
        nYes = yesPercent;
        nNo = noPercent;
    }
    // function get(Data storage self, uint proposalId) public view returns (Proposal proposal) {
    //    return self.proposals[proposalId];
    // }
    function getProposalType(Data storage self, uint proposalId) internal view returns (ProposalType) {
        return self.proposals[proposalId].proposalType;
    }
    function getSpecHash(Data storage self, uint proposalId) internal view returns (bytes32) {
        return self.proposals[proposalId].specHash;
    }
    function getProposalId(Data storage self, bytes32 specHash) internal view returns (uint256) {
        return self.specHashToId[specHash];
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


contract VotingAlpha is Operated {
    using SafeMath for uint;
    using MembersInternal for MembersInternal.Data;
    using ProposalsInternal for ProposalsInternal.Data;

    MembersInternal.Data members;
    ProposalsInternal.Data proposals;

    // Must be copied here to be added to the ABI
    event MemberAdded(address indexed memberAddress, uint totalAfter);
    event MemberRemoved(address indexed memberAddress, uint totalAfter);

    event NewProposal(uint indexed proposalId, ProposalsInternal.ProposalType indexed proposalType, address indexed proposer);
    event Voted(uint indexed proposalId, address indexed voter, bool vote, uint votedYes, uint votedNo);


    // ----------------------------------------------------------------------------
    /// @dev Initialisation functions
    // ----------------------------------------------------------------------------

    /// @dev Run this first to set the contract owner. 
    function initVotingAlpha() public {
        require(!members.isInitialised());
        _initOperated(msg.sender);
    }

    function initAddMember( address _address) public  {
        require(isOwner());
        members.add(_address, "");
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
    function createNewBill(bytes32 _specHash) public  returns (uint proposalId) {
        require(operators[msg.sender]);
        proposalId = proposals.proposeNationalBill(_specHash);
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
        /// @dev This can be used for more than one proposal type
        // ProposalsInternal.ProposalType proposalType = proposals.getProposalType(proposalId);
        if (proposals.toExecute(proposalId)) {
            proposals.close(proposalId);
        }
    }


    // ----------------------------------------------------------------------------
    /// @dev Members
    // ----------------------------------------------------------------------------
    
    function addMember(address memberAddress) internal {
        members.add(memberAddress, "");
    }
    function removeMember(address memberAddress) internal {
        members.remove(memberAddress);
    }

    function operatorAddMember( address _address) public  {
        require(operators[msg.sender]);
        members.add(_address, "");
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
    function getProposal(uint proposalId) public view returns (uint _proposalType, address _proposer, bytes32 _specHash, uint _votedNo, uint _votedYes, uint _initiated, uint _closed) {
        ProposalsInternal.Proposal memory proposal = proposals.proposals[proposalId];
        _proposalType = uint(proposal.proposalType);
        _proposer = proposal.proposer;
        _specHash = proposal.specHash;
        _votedNo = proposal.votedNo;
        _votedYes = proposal.votedYes;
        _initiated = proposal.initiated;
        _closed = proposal.closed;
    }

    function getSpecHash(uint proposalId) public view returns (bytes32) {
        return proposals.getSpecHash(proposalId);
    }
    function getProposalId( bytes32 specHash) public view returns (uint256) {
        return proposals.getProposalId(specHash);
    }


    /// @dev Results for a given proposal ID
    function getVotingStatus(uint proposalId) public view returns ( bool isOpen, uint voteCount, uint yesPercent, uint noPercent, uint nVotes, uint nYes, uint nNo) {
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
        MembersInternal.Member memory member = members.entries[memberAddress];
        return (member.exists, member.index, member.name);
    }

}
