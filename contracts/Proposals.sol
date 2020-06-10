pragma solidity ^0.6.9;

import "./Members.sol";
import "./Owned.sol";
import "./SafeMath.sol";


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
