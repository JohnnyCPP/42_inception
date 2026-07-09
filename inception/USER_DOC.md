# User Documentation - Inception Project

## Overview

This document provides simple instructions for end users and administrators of the Inception project. It explains what services are available, how to manage them, and how to verify everything is working correctly.

## Services Provided

The project consists of three main services that work together to host a WordPress website:

### 1. NGINX Web Server

- **What it does**: Acts as the "front door" to your website
- **Function**: Handles all incoming web traffic, serves web pages, and manages secure HTTPS connections
- **Access**: Only this service is accessible from outside the system (via port 443)

### 2. WordPress + PHP-FPM

- **What it does**: Runs the WordPress application
- **Function**: Processes PHP code, generates dynamic content, and manages blog posts, pages, and user interactions
- **Access**: Not directly accessible from outside; only NGINX can communicate with it

### 3. MariaDB Database

- **What it does**: Stores all website data
- **Function**: Manages WordPress content, user accounts, settings, and post data
- **Access**: Only WordPress can communicate with it (not accessible from outside)

## Starting and Stopping the Project

### Quick Start

The project uses `make` commands to manage everything. Here are the essential commands:

#### Start the Project

This command builds all Docker images, creates containers, and starts them automatically. Use this the first time or after a full cleanup.

```bash
make all
```

This stops all containers gracefully. Your data is preserved in volumes.

```bash
make stop
```

Stops and then starts all containers again. Useful after configuration changes.

```bash
make restart
```

Shows if containers are running, stopped, or encountering issues.

```bash
make status
```

Common management commands:

- make help: Describes all commands
- make clean: Removes containers and images
- make fclean: Removes containers, images, AND data
- make start: Starts existing containers (if stopped)
- make stop: Stops running containers
- make restart: Restarts all containers
- make status: Shows current container status
- make log: Shows real-time logs from all services
- make log-nginx: Shows only NGINX logs
- make log-wordpress: Shows only WordPress logs
- make log-mariadb: Shows only MariaDB logs

## Accessing The Website

1. Configure your domain by adding this line to /etc/hosts, replacing login with your 42 login: "127.0.0.1 login.42.fr"
2. Ensure the project is running (use make status to check)o
3. Open your browser and go to: https://login.42.fr

You'll see a security warning about the certificate because it's self-signed. This is normal. Click "Advanced" and then "Proceed to site" or "Accept the risk".

## Accessing The Administrator Panel

1. To manage your WordPress site (create posts, change themes, add users), go to: https://login.42.fr/wp-admin
2. Login with the administrator credentials

## Locating Credentials

All credentials are stored in the .env file at the root of the project.

## Changing Credentials

1. Edit the .env file with your new values
2. Restart the containers: "make restart"

If you change database credentials, you'll need to recreate the MariaDB container and reconfigure WordPress.

## Checking Service Health

Run "make status", which shows:

- Container Names (nginx, wordpress, mariadb)
- Status (Up, Exited, Restarting)
- Health (healthy, unhealthy, starting)
- Ports (which ports are exposed)
