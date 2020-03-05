#!/usr/bin/env bash

echo '{"experimental":true}' | sudo tee /etc/docker/daemon.json
sudo mkdir $HOME/.docker
sudo touch $HOME/.docker/config.json
echo '{"experimental":"enabled"}' | sudo tee $HOME/.docker/config.json
sudo service docker restart
