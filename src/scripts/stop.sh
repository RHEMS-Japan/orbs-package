#!/bin/bash

# stop
sudo twingate stop

# test public resource after stop
curl -v -m 10 http://twingate.com > /dev/null
