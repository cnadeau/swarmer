#!/bin/bash

set -ueo pipefail

docker-machine rm -f swarm-agent-n1
docker-machine rm -f swarm-agent-n2
docker-machine rm -f swarm-master
docker-machine rm -f swarm-keystore
