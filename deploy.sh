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
# Remove the swarm-master from the docker/swarm/nodes kv
curl -X "DELETE" http://$(docker-machine ip swarm-keystore):8500/v1/kv/docker/swarm/nodes/$(docker-machine ip swarm-master):2376


# Use a socat proxy to expose non-TLS port 2375
docker run -d -p 2375:2375 --volume=/var/run/docker.sock:/var/run/docker.sock --name=docker-http sequenceiq/socat

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-agent-n1

#docker-machine create \
#  -d virtualbox \
#  --swarm \
#  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
#  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
#  --engine-opt="cluster-advertise=eth1:2376" \
#  swarm-agent-n2

eval $(docker-machine env --swarm swarm-master)

docker info

echo "Run: eval \$(docker-machine env --swarm swarm-master)"

# Setup a swarm to reproduce interlock issue https://github.com/ehazlett/interlock/issues/114
SWARM_HOST=tcp://$(docker-machine ip swarm-master):2375 docker-compose up -d
