#!/bin/bash

set -ueo pipefail

docker-machine create \
  -d virtualbox \
  swarm-keystore
eval $(docker-machine env swarm-keystore)

docker run -d \
  -p "8500:8500" \
  -h "consul" \
  progrium/consul -server -bootstrap

docker-machine create \
  -d virtualbox \
  --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-master

# Stop and remove swarm-agent to remove the master from the swarm nodes (https://github.com/docker/machine/issues/2302)
eval $(docker-machine env swarm-master)
docker stop swarm-agent
docker rm swarm-agent

eval $(docker-machine env swarm-keystore)

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-agent-n1

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-agent-n2

eval $(docker-machine env --swarm swarm-master)

docker info

echo "Run: eval \$(docker-machine env --swarm swarm-master)"
