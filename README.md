# Voting Alpha

A basic voting contract for the DigiPol MVP


.

------------------------------

.

.

## Smart Contracts (Developers) 

### Installing Brownie

Install PipX
`python3 -m pip install --user pipx`

`python3 -m pipx ensurepath`

Install using PipX
`pipx install eth-brownie`

### Compiling the contracts

Compile updated contracts: `brownie compile`

Compile all contracts (even not changed ones): `brownie compile --all`

### Running tests

Run tests: `brownie test`

Run tests in verbose mode: `brownie test -v`

Check code coverage: `brownie test --coverage`

Check available fixtures: `brownie --fixtures .`


### Brownie commands

Run script: `brownie run <script_path>`

Run console (very useful for debugging): `brownie console`

### Deploying TimesSquare Contract

Run script: `brownie run scripts/deploy_VotingAlpha.py`


## Testing with Docker

A Dockerfile is available if you are experiencing issues testing locally.

run with:
`docker build -f Dockerfile -t brownie .`
`docker run -v $PWD:/usr/src brownie pytest tests`