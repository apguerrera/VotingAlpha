# TimesSquare

A contract to celebrate the joy of countdowns!!

Last name up before the timer ends, wins the prize!

## How to play

### Deposit
Deposit the minimum amount to play. The more you donate, the greater the joy. 

### Countdown
The timer begins from the time the contact was first deployed.

There is a set number of periods till the end. 

Game ends when timer reaches 0

Winner can withdraw all the money in the contract!

### How to win
Simply add tokens to the contract. 

Any tokens added, will add periods time to the clock.

If you are the last person to contribute before the contract ends, you win.

### Claim Prize

If you are the last person and your address is the winner, simply withdraw the winning tokens. 

.

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

Run script: `brownie run scripts/deploy_TimesSquare.py`


## Testing with Docker

A Dockerfile is available if you are experiencing issues testing locally.

run with:
`docker build -f Dockerfile -t brownie .`
`docker run -v $PWD:/usr/src brownie pytest tests`