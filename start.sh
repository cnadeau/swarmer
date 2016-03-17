#!/bin/bash

set -ueo pipefail

docker-machine start swarm-keystore
docker-machine start swarm-master
docker-machine start swarm-agent-n1
docker-machine start swarm-agent-n2
