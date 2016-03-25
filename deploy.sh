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
