# Voting Alpha

A basic voting contract for the DigiPol MVP


.

------------------------------

.

.

## Smart Contracts (Developers) 

### Installing Brownie (auto)

> **bleeding edge setup script: `./_setup/01_install_deps.hs`**

### Installing Brownie (manual)

Install PipX
`python3 -m pip install --user pipx`

`python3 -m pipx ensurepath`

Install using PipX
`pipx install eth-brownie`

### Brownie commands

Compile updated contracts: `brownie compile`

Compile all contracts (even not changed ones): `brownie compile --all`

Run script: `brownie run <script_path>`

Run console (very useful for debugging): `brownie console`

For a console to the Flux/SecureVote chain, use `--network` and see details below

### Deploying Contract

Run script: `brownie run scripts/deploy_VotingAlpha.py`

### Deploying to SecureVote Chain

* Add SecureVote chain ID: `brownie networks add Ethereum securevote host=http://54.153.142.251:8545/ chainid=0x8c25bce6`
* Deploy script: `brownie run deploy_VotingAlpha.py --network securevote`
* New Proposal: `brownie run deploy_NewProposal.py --network securevote`
* Submit Vote: `brownie run deploy_SubmitVote.py --network securevote`
* Console: `brownie console --network securevote`

### Running tests

Run tests: `brownie test`

Run tests in verbose mode: `brownie test -v`

Check code coverage: `brownie test --coverage`

Check available fixtures: `brownie --fixtures .`



## Testing with Docker

A Dockerfile is available if you are experiencing issues testing locally.

run with:
`docker build -f Dockerfile -t brownie .`
`docker run -v $PWD:/usr/src brownie pytest tests`

## Methods

```
initialised()
setOperated(bool)
operators(address)
initComplete()
operatorAddMember(address)
getMemberData(address)
getProposalId(bytes32)
isOperator()
initAddOperator(address)
isOperated()
initAddMember(address)
initVotingAlpha()
voteNo(bytes32)
numberOfProposals()
owner()
isOwner()
getVotingStatus(uint256)
addOperator(address)
getMembers()
numberOfMembers()
operatorRemoveMember(address)
removeOperator(address)
getMemberByIndex(uint256)
getProposal(uint256)
initRemoveMember(address)
voteYes(bytes32)
getSpecHash(uint256)
mOwner()
createNewBill(bytes32)
```
