from brownie import *


def deploy_voting_alpha(voting_alpha_address):
    voting_alpha = VotingAlpha.at(voting_alpha_address)
    return voting_alpha

def submit_yes_vote(voting_alpha, proposal_id):
    voting_alpha.voteYes(proposal_id,{"from": accounts[1]})

def main():
    # add accounts if active network is ropsten
    if network.show_active() == 'ropsten':
        # 0x2A40019ABd4A61d71aBB73968BaB068ab389a636
        accounts.add('4ca89ec18e37683efa18e0434cd9a28c82d461189c477f5622dae974b43baebf')
        # 0x1F3389Fc75Bf55275b03347E4283f24916F402f7
        accounts.add('fa3c06c67426b848e6cef377a2dbd2d832d3718999fbe377236676c9216d8ec0')
        voting_alpha_address = web3.toChecksumAddress(0x89FaE90b27B235DCdD8C6615a6c88BDFFBb8856D)
  

    voting_alpha =  deploy_voting_alpha(voting_alpha_address)
    submit_yes_vote(voting_alpha, 0)
 