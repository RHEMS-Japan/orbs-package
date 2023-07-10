#!/bin/bash

SERVICE_KEY=$(eval echo \$"${KEY_ENV}")
export SERVICE_KEY
echo "${SERVICE_KEY}"
if [[ -z "$SERVICE_KEY" ]]; then
  echo "Need to set parameters.service-key non-empty."
  echo "Or set the value to environment variable TWINGATE_SERVICE_KEY."
  exit 1
fi

echo "$SERVICE_KEY" | base64 --decode | sudo twingate setup --headless=-
sudo twingate start

# collect logs
sudo journalctl -u twingate --no-pager | tail -n 20