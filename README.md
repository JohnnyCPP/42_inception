# Inception

![image](./resource/42_madrid.jpg)

> 42 Madrid is an academy for values, attitude and learning "hard and soft skills" in the digital environment.

## Project Overview

Inception is about building a small infrastructure entirely from scratch using
Docker Compose, where each service runs in its own dedicated container.

Stack:

- NGINX: Web server with TLSv1.2/TLSv1.3 encryption (port 443 only)
- WordPress + PHP-FPM: Content management system
- MariaDB: Database server
- Alpine Linux (or Debian)

The services are three containers orchestrated with Docker Compose:

- nginx on port 443
- wordpress on port 9000 (internal)
- mariadb on port 3306 (internal)

Key features:

- Custom Dockerfiles (no pre-built images)
- Environment variables for configuration
- Persistent named volumes
- Auto-restart on container crash
- Multi-service orchestration
- Secure TLS encryption

## Run

TODO
