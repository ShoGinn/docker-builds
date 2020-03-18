#!/usr/bin/env bash

set -o errexit # Exit on most errors (see the manual)
#set -o errtrace # Make sure any error trap is inherited
set -o nounset  # Disallow expansion of unset variables
set -o pipefail # Use last non-zero exit code in a pipeline
set -o xtrace   # Trace the execution of the script (debug)

echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json
mkdir "$HOME/.docker"
touch "$HOME/.docker/config.json"
echo '{"experimental":"enabled"}' | sudo tee "$HOME/.docker/config.json"
sudo service docker restart
