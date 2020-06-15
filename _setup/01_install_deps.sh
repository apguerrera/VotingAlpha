#!/usr/bin/env bash

if ! (which brownie >/dev/null); then
  if ! (which pipx >/dev/null); then
    python3 -m pip install --user pipx || echo "FAILED: pip3 install pipx"
    python3 -m pipx ensurepath || echo 'pipx is not in our $PATH! Check install and config'
  fi
  pipx install eth-brownie || echo 'FAILED: pipx install eth-brownie'
fi

echo 'Setup complete. Use `brownie` to interact'


