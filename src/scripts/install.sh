#!/bin/bash

sudo apt update -yq
sudo apt install -yq ca-certificates
echo "deb [trusted=yes] https://packages.twingate.com/apt/ /" | sudo tee /etc/apt/sources.list.d/twingate.list
sudo apt update -yq
sudo apt install -yq twingate
