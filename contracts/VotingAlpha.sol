pragma solidity ^0.5.4;

import "./Members.sol";
import "./Proposals.sol";
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
    function proposeNationalBill(bytes32 _specHash) public  returns (uint proposalId) {
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
        // Proposals.ProposalType proposalType = proposals.getProposalType(proposalId);
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
    function getProposal(uint proposalId) public view returns (uint _proposalType, address _proposer, bytes32 _specHash, uint _votedNo, uint _votedYes, uint _initiated, uint _closed) {
        Proposals.Proposal memory proposal = proposals.proposals[proposalId];
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