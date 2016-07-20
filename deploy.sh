#!/bin/bash

set -ueo pipefail

# Create a virtual machine for the keystore
docker-machine create \
  -d virtualbox \
  swarm-keystore

# switch docker environement variables to target the swarm-keystore docker daemon
eval $(docker-machine env swarm-keystore)

# start a consul container to create a server into the swarm-keystore machine
# to manager service discovery
docker run -d \
  -p "8500:8500" \
  -h "consul" \
  progrium/consul -server -bootstrap

# create the swarm master, registring it into the swarm-keystore and use the swarm-keystore as service discovery engine
docker-machine create \
  -d virtualbox \
  --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-master

## Small hack to ensure the swarm-master machine does not contain a swarm-agent able to run container
## since we want it to be 100% dedicated to swarm agents management
# Stop and remove swarm-agent to remove the master from the swarm nodes (https://github.com/docker/machine/issues/2302)
eval $(docker-machine env swarm-master)
docker stop swarm-agent
docker rm swarm-agent

# Remove the swarm-master from the docker/swarm/nodes kv
curl -X "DELETE" http://$(docker-machine ip swarm-keystore):8500/v1/kv/docker/swarm/nodes/$(docker-machine ip swarm-master):2376

# create a swarm node machine and use the swarm-keystore as service discovery
docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-agent-n1

# create another swarm node machine and use the swarm-keystore as service discovery
docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip swarm-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-agent-n2

echo
echo

# switch docker environement variables to target swarm-master docker daemon
eval $(docker-machine env --swarm swarm-master)

# display the current information about the swarm master
docker info

echo "Run: eval \$(docker-machine env --swarm swarm-master) to run commands in the docker swarm-master node" 
