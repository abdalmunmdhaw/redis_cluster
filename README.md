# Redis Cluster with Docker Compose

This project provides a simple and fast way to set up a 6-node Redis Cluster (3 Masters and 3 Replicas) using Docker and Docker Compose. The cluster is configured for durability with AOF persistence enabled and is secured with a password.

## Key Features

*   **High Availability Cluster**: Consists of 3 master nodes and 3 replica nodes, ensuring service continuity if a master node fails.
*   **Simple Setup**: A single `make` command is all you need to provision and launch the entire cluster.
*   **Data Persistence**: Uses Append Only File (AOF) to ensure that no data is lost when containers are restarted.
*   **Password Protected**: All nodes are protected with a password for client connections and internal node-to-node authentication.
*   **Network-Ready Configuration**: Uses `--cluster-announce-ip` to allow the cluster to work correctly across different Docker networking environments.

## Prerequisites

Before you begin, ensure you have the following tools installed on your system:

*   Docker
*   Docker Compose
*   `make`

## Configuration

Before launching the cluster, you must perform one important configuration step.

### Set the Host IP Address

Open the `Makefile` and locate the `HOST_IP` variable. Change its value from `192.168.88.102` to your machine's local network IP address (LAN IP).

```makefile
# ... (other content)

# !!! IMPORTANT: Change this to your host machine's IP address
HOST_IP=192.168.88.102

# ... (other content)
```

**Why is this important?**
Redis nodes use this IP address to announce themselves to other nodes and to clients. If this is not set correctly, the nodes will not be able to communicate with each other to form the cluster.

### (Optional) Change the Password

You can change the default password (`redis123`) by modifying the `REDIS_PASSWORD` variable in the `Makefile`.

## Running the Cluster

To launch the cluster, open a terminal in the project's root directory and run the following command:

```bash
make create-cluster
```

This command will automatically perform the following steps:

1.  `create-folders`: Creates the necessary data directories (`data/redis-*`) for persistent storage for each node.
2.  `docker compose up -d`: Builds and starts the 6 Redis containers in the background, based on the `docker-compose.yml` configuration.
3.  `redis-cli --cluster create`: Executes a `redis-cli` command inside one of the containers to join the 6 nodes together and form the cluster.

## Verifying the Cluster Status

After the setup command completes successfully, you can verify that the cluster is running correctly.

### Check Running Containers

```bash
docker ps
```

You should see 6 containers named `redis-master1` through `redis-replica3`, all in an `Up` state.

### Check the Cluster Status via redis-cli

Execute the following command to check the role distribution and slot assignments:

```bash
docker exec -it redis-master1 redis-cli -a redis123 -p 7000 CLUSTER NODES
```

The output will list all nodes in the cluster, indicating which are master and slave (replica), and their connection status.

## Connecting to the Cluster

To connect to the cluster from your application, you must use a Redis client library that supports cluster mode. When connecting, you can use the address of any of the nodes.

*   **Endpoints**: `YOUR_HOST_IP:7000`, `YOUR_HOST_IP:7001`, etc.
*   **Password**: `redis123` (or the password you configured).

Example of connecting using `redis-cli` in cluster mode (`-c`):

```bash
redis-cli -c -h YOUR_HOST_IP -p 7000 -a redis123
```

## Shutdown and Cleanup

To stop and remove the containers, networks, and volumes created by Docker Compose:

```bash
docker compose down
```

**Note**: This command does not delete the persistent data in the `./data` directory.

If you want to completely wipe all cluster data and start fresh, you can add the following target to your `Makefile`:

```makefile
clean:
	@sudo rm -rf data
	@echo "All data folders have been removed."
```

And then run it with:

```bash
make clean
```

## File Structure

*   `Makefile`: Contains shortcut commands to simplify the process of creating and managing the cluster.
*   `docker-compose.yml`: The main configuration file that defines the services (Redis containers), ports, volumes, and startup commands for each node.
*   `data/`: The directory created to store the `nodes.conf` and `appendonly.aof` files for each node, ensuring data persistence across restarts.