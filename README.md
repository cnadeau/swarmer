# Swarmer
Script to run a Docker Swarm on Docker Toolbox

# Create the Swarm Cluster

`deploy.sh`

# Start the docker-compose.yml stack inside the cluster

```bash
# setup the docker environment variables to target the swarm master
eval $(docker-machine env --swarm swarm-master)

# deploy the docker-compose stack using the swarm master
docker-compose up -d

# Find the address on which the load balancer is hosted
docker ps | grep lb

# Something similar to `xxx.xxx.xxx.xxx:9000->80/tcp`

# check the actual load balancer configuration
docker-compose logs lb

# scale to get 4 web containers
docker-compose scale web=4

# check the actual load balancer configuration to see the new containers were detected
docker-compose logs lb

# view the distribution of containers between Swarm Nodes
docker ps

# view the Swarm Nodes information
docker info
```

# To access the Hello World application

## Find the address on which the load balancer is hosted

docker ps | grep lb

Something similar to `xxx.xxx.xxx.xxx:9000->80/tcp`

You will be able to see the Hello World within a browser and see the hostname (defaults to container's ID) in the browser

__IMPORTANT__
If you want to go back to your local setup of Docker, you need to unset the environment variables as follow:

docker-machine env --unset