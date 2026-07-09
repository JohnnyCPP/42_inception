# Developer Documentation - Inception Project

## Overview

This document provides technical documentation for developers working on the Inception project. It covers environment setup, build processes, container management, and data persistence.

## Environment Setup

### Prerequisites

- **OS**: Debian/Ubuntu Linux
- **Docker Engine**: 20.10+
- **Docker Compose Plugin**: 2.0+
- **Make**: 4.0+
- **Git**: Latest
- **Disk Space**: 2GB minimum
- **Memory**: 2GB minimum

### Install Docker

```bash
# Install prerequisites
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release make

# Add Docker repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Configuration Files

First, create .env at project root: 

```
DOMAIN_NAME=login.42.fr

# MariaDB
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=user_password

# WordPress Admin (cannot contain "admin" or "administrator")
WP_ADMIN_USER=your_admin_username
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=admin@example.com

# WordPress Regular User
WP_USER=regular_user
WP_USER_PASSWORD=regular_user_password
WP_USER_EMAIL=user@example.com

WP_URL=https://${DOMAIN_NAME}
```

Then, create srcs/docker-compose.yml for service orchestration.

Write the dockerfiles:

- srcs/requirements/nginx/Dockerfile
- srcs/requirements/wordpress/Dockerfile
- srcs/requirements/mariadb/Dockerfile

Write the entrypoint scripts:

- srcs/requirements/wordpress/conf/entrypoint.sh
- srcs/requirements/mariadb/conf/entrypoint.sh

Secrets are managed by environment variables stored in the .env file.

Remember to add the .env file in a .gitignore file to avoid pushing it to the repository by accident.

### Directory Setup

```bash
# Create data directories
mkdir -p /home/login/data/wp_files
mkdir -p /home/login/data/wp_db
sudo chown -R $USER:$USER /home/login/data

# Configure hosts file
echo "127.0.0.1 login.42.fr" | sudo tee -a /etc/hosts
```

### Verify Setup

```bash
# Check Docker
docker --version
docker compose version

# Check directory permissions
ls -la /home/login/data

# Verify .env exists
cat .env

# Test configuration
docker compose -f srcs/docker-compose.yml config
```

## Build and Launch

### Makefile Commands

The Makefile provides automation for building and managing the project.

Run "make help" to list all commands and see a description of what they do.

### Usage Examples

```bash
# First time setup
make all

# Rebuild a specific service
make build-nginx
make restart

# Stop all services
make stop

# Start stopped services
make start

# Full rebuild
make re

# Check status
make status

# View logs
make log
make log-nginx
```

### Manual Docker Compose

```bash
# Build images
docker compose -f srcs/docker-compose.yml build

# Build specific service
docker compose -f srcs/docker-compose.yml build nginx

# Start in background
docker compose -f srcs/docker-compose.yml up -d

# Stop containers
docker compose -f srcs/docker-compose.yml stop

# Stop and remove containers
docker compose -f srcs/docker-compose.yml down

# View logs
docker compose -f srcs/docker-compose.yml logs -f
```

## Container and Volume Management

### Container Commands

```bash
# List all containers
docker ps -a

# List running containers
docker ps

# Check container health
make status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Inspect container details
docker inspect nginx
docker inspect wordpress
docker inspect mariadb

# View container logs
make log-nginx
docker logs nginx
docker logs -f nginx

# Check resource usage
docker stats
```

```bash
# Start containers
make start
docker start nginx wordpress mariadb

# Stop containers
make stop
docker stop nginx wordpress mariadb

# Restart containers
make restart
docker restart nginx wordpress mariadb

# Stop and remove containers
make down
docker compose -f srcs/docker-compose.yml down
```

### Volume Commands

```bash
# List volumes
docker volume ls
make vol

# Inspect volume details
docker volume inspect wp_files
docker volume inspect wp_db

# Show mount points
make volmnt
docker volume ls -q | xargs -I {} sh -c 'echo "{}: $(docker volume inspect {} --format={{.Options.device}})"'
```

```bash
# Clean volume contents
make rm_vol_content

# Manual clean
docker run --rm -v wp_files:/mnt alpine sh -c "rm -rf /mnt/*"
docker run --rm -v wp_db:/mnt alpine sh -c "rm -rf /mnt/*"

# Remove volumes
make rm_volumes
docker volume rm wp_files wp_db
```
