#!/bin/bash

set -ueo pipefail

docker-machine start swarm-keystore
docker-machine start swarm-master
docker-machine start swarm-agent-n1
docker-machine start swarm-agent-n2

echo "Run: eval \$(docker-machine env --swarm swarm-master) to run commands in the docker swarm-master node"
