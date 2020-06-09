
from brownie import accounts, web3, Wei, rpc
from brownie.network.transaction import TransactionReceipt
from brownie.convert import to_address
import pytest
from brownie import Contract
from settings import *

######################################
# Deploy Contracts
######################################



@pytest.fixture(scope='module', autouse=True)
def voting_alpha(VotingAlpha, Members, Proposals):
    members = Members.deploy({"from": accounts[0]})
    proposals = Proposals.deploy({"from": accounts[0]})
    voting_alpha = VotingAlpha.deploy({"from": accounts[0]})
    return voting_alpha


