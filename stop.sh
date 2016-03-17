#!/bin/bash

set -ueo pipefail

docker-machine stop swarm-agent-n1
docker-machine stop swarm-agent-n2
docker-machine stop swarm-master
docker-machine stop swarm-keystore
