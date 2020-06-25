from brownie import accounts, web3, Wei, reverts, rpc
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract
from settings import *


# reset the chain after every test case
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


def test_init_voting_alpha(voting_alpha):
    assert voting_alpha.numberOfProposals() == 0
    assert voting_alpha.numberOfMembers() == 1


def test_voting_alpha_createNewBill(voting_alpha):
    spec_hash = "FirstBillSpecHash".encode()
    spec_hash_hex = '0x'+spec_hash.hex()
    tx = voting_alpha.createNewBill(spec_hash_hex, {"from": accounts[1]})

    proposal_id = voting_alpha.getProposalId(spec_hash_hex)
    assert voting_alpha.getSpecHash(proposal_id) == spec_hash_hex
    assert voting_alpha.getProposalId(spec_hash_hex) == proposal_id

