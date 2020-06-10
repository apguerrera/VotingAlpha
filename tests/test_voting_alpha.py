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

def test_voting_alpha_proposeNationalBill():
    bill_text = "This is the first bill"
    tx = voting_alpha.proposeNationalBill(bill_text, {"from": accounts[1]})