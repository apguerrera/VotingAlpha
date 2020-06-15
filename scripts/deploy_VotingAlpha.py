import json

from brownie import *


def deploy_voting_alpha():
    # Deploy required library contracts
    # members = Members.deploy({"from": accounts[0]})
    # proposals = Proposals.deploy({"from": accounts[0]})

    # Deploy the Voting contracts and initialise
    voting_alpha = VotingAlpha.deploy({"from": accounts[0], "gas_limit": 2000000})
    voting_alpha.initVotingAlpha({"from": accounts[0], "gas_limit": 2000000})
    voting_alpha.initAddOperator(accounts[1], {"from": accounts[0], "gas_limit": 2000000})
    voting_alpha.initAddMember(accounts[1], {"from": accounts[0], "gas_limit": 2000000})
    voting_alpha.initComplete({"from": accounts[0]})
    return voting_alpha


def main():
    print(f"VotingAlpha dir: {dir(VotingAlpha)}")

    with open('VotingAlpha.bin', 'w') as f:
        f.write(VotingAlpha.bytecode)
    with open('VotingAlpha.abi.json', 'w') as f:
        f.write(json.dumps(VotingAlpha.abi))

    # add accounts if active network is ropsten
    if network.show_active() in ['ropsten', 'securevote']:
        # 0x2A40019ABd4A61d71aBB73968BaB068ab389a636
        accounts.add('4ca89ec18e37683efa18e0434cd9a28c82d461189c477f5622dae974b43baebf')
        # 0x1F3389Fc75Bf55275b03347E4283f24916F402f7
        accounts.add('fa3c06c67426b848e6cef377a2dbd2d832d3718999fbe377236676c9216d8ec0')

    voting_alpha = deploy_voting_alpha()
