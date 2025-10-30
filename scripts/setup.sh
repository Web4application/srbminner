#!/bin/bash
echo "Setting up SRBMinner environment..."
mkdir -p miner/build
pip install -r ai/requirements.txt
pip install -r web/requirements.txt
echo "Setup complete."
