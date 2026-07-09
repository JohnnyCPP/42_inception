*This project has been created as part of the 42 curriculum by jonnavar.*

## Description

Inception is a system administration project that demonstrates the practical application of containerization and orchestration technologies. The goal is to build a complete WordPress website infrastructure using Docker containers, following specific architectural constraints and best practices.

The project consists of three main services, each running in its own container:
- **NGINX**: A web server that serves as the sole entry point, configured with TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM**: A PHP application server running WordPress without a web server
- **MariaDB**: A relational database management system for storing WordPress data

All services are orchestrated using Docker Compose, with persistent data stored in named volumes and communication happening over a dedicated Docker network.

### Project Architecture

```
                    ┌────────────────────────────────────────────┐
                    │            DOCKER NETWORK                  │
                    │            (inception)                     │
                    │                                            │
                    │    ┌──────────────┐                        │
User ──── HTTPS ───►│───►│   NGINX      │                        │
                    │    │  (Port 443)  │                        │
                    │    │   Web Server │                        │
                    │    └──────┬───────┘                        │
                    │           │                                │
                    │           │ FastCGI (PHP-FPM)              │
                    │           │ Port 9000                      │
                    │           ▼                                │
                    │    ┌──────────────┐                        │
                    │    │  WORDPRESS   │                        │
                    │    │  + PHP-FPM   │                        │
                    │    │   Processes  │                        │
                    │    │   PHP Code   │                        │
                    │    └──────┬───────┘                        │
                    │           │                                │
                    │           │ MySQL Protocol                 │
                    │           │ Port 3306                      │
                    │           ▼                                │
                    │    ┌──────────────┐                        │
                    │    │   MARIADB    │                        │
                    │    │   Database   │                        │
                    │    │   Service    │                        │
                    │    └──────────────┘                        │
                    │                                            │
                    └────────────────────────────────────────────┘
```

### Services Overview

NGINX:

- Container: nginx
- Port: 443 (exposed to host)
- Base Image: Alpine 3.23.5 (image digest)
- Purpose: Web server, SSL termination, single entry point
- Features: TLSv1.2/TLSv1.3 only, self-signed certificates

WORDPRESS + PHP-FPM:

- Container: wordpress
- Port: 9000 (internal only)
- Base Image: Alpine 3.23.5 (image digest)
- Purpose: PHP application server, runs WordPress CMS
- Features: WP-CLI for installation, two users (admin + subscriber)

MARIADB:

- Container: mariadb
- Port: 3306 (internal only)
- Base Image: Alpine 3.23.5 (image digest)
- Purpose: Relational database, stores WordPress data
- Features: Initialized with WordPress database and users

VOLUMES:

- wp_files: /home/jonnavar/data/wp_files - WordPress files
- wp_db: /home/jonnavar/data/wp_db - Database storage

NETWORK:

- Name: inception
- Driver: bridge
- Purpose: Internal communication between containers

DOMAIN:

- jonnavar.42.fr -> localhost (127.0.0.1)

### Design Choices

All containers are built from **Alpine Linux 3.23.5**, chosen for its:

- Minimal footprint (~5MB)
- Security-focused design
- Fast package management
- Active community and regular updates

Each service runs in its own container with:

- Minimal required packages only
- Dedicated user for runtime (nobody for WordPress, mysql for MariaDB)
- Limited permissions and capabilities

Security:

- **SSL/TLS**: Self-signed certificates with TLSv1.2/v1.3 only (no older, insecure protocols)
- **Credential Management**: All passwords and secrets in `.env` (excluded from Git)
- **Network Security**: Only NGINX port 443 exposed; internal services inaccessible from host
- **Container Hardening**: Processes run as non-root users where possible
- **Health Checks**: Integrated to monitor service availability

Two named volumes:

- `wp_files`: Stores WordPress core files, themes, and plugins (`/home/jonnavar/data/wp_files`)
- `wp_db`: Stores MariaDB database files (`/home/jonnavar/data/wp_db`)

### Virtual Machines vs Docker

**Virtual Machines:**

- Emulate complete hardware systems with their own OS kernel
- Heavy resource usage (GBs of storage, significant RAM)
- Slow startup times (minutes)
- Full isolation with hardware virtualization
- Snapshots of the entire system state

**Docker Containers:**

- Share the host OS kernel and system resources
- Lightweight (MBs of storage, minimal overhead)
- Near-instant startup (seconds)
- Process-level isolation using namespaces and cgroups
- Immutable images with ephemeral containers

**Why Docker for this project:**

Docker was chosen because it aligns perfectly with the project requirements: It needs lightweight, fast, and reproducible environments. Each service runs in isolation but efficiently shares resources, making it ideal for microservices architecture. The ability to define infrastructure as code using Dockerfiles and docker-compose.yml ensures consistency across different environments.

### Secrets vs Environment Variables

**Environment Variables:**

- Plain text values passed to containers at runtime
- Visible in container inspect and process lists
- Suitable for non-sensitive configuration (e.g., service names, URLs)
- Easy to implement and debug

**Docker Secrets:**

- Encrypted and stored securely in Docker Swarm
- Mounted as files in containers (read-only)
- Only accessible to services that have been granted access
- Rotated without restarting services

**Why Environment Variables for this project:**

The project mandates the use of environment variables for simplicity and compatibility with the 42 curriculum requirements. While Docker secrets would be more secure, environment variables are appropriate for educational purposes and are explicitly required by the subject. All sensitive information is stored in a `.env` file that is excluded from version control via `.gitignore`.

### Docker Network vs Host Network

**Host Network Mode:**

- Container uses host's network stack directly
- No network isolation
- Performance overhead is minimal
- Port conflicts with other services possible
- Security risk: container has full access to host network

**Docker Bridge Network (User-Defined):**

- Each container gets its own network namespace
- Internal DNS resolution between containers
- Isolated from host network
- Only explicitly exposed ports are accessible
- Security through network segmentation

**Why Docker Bridge Network:**

The project specifically forbids `network: host`, requiring a dedicated Docker network. This provides service discovery through container names (e.g., `wordpress:9000`), isolates services from the host, and creates a secure internal network where containers can communicate without exposing unnecessary ports to the outside world. Only NGINX exposes port 443 to the host.

### Docker Volumes vs Bind Mounts

**Bind Mounts:**

- Direct mapping of a host directory to a container
- Modifications in container reflect immediately on host
- Host-dependent path (not portable)
- No management by Docker (manual directory creation required)
- Less secure (container can modify host files)

**Docker Named Volumes:**

- Managed entirely by Docker
- Stored in Docker's volume directory by default
- Can be assigned custom mount points using driver options
- Portable across different Docker hosts
- Better performance
- Backup and restore capabilities

**Why Named Volumes with Bind Mounts:**

The project requires named volumes that store data at `/home/jonnavar/data/` on the host. This combines the management benefits of named volumes with specific host location requirements using `driver_opts` with `type: none` and `o: bind`. This approach:

- Ensures persistent data survives container restarts
- Makes backups straightforward (data is on the host filesystem)
- Allows inspection of WordPress files from the host
- Fulfills project requirements for volume management

## Instructions

### Prerequisites

- Docker Engine 20.10+
- Docker Compose Plugin 2.0+
- A Debian virtual machine
- Git
- Make

Clone the repository and run the following make targets:

```bash
make help
make inception
make status
```

## Resources

References consulted for this project are listed below:

### Alpine

Search packages for Alpine Linux

- https://pkgs.alpinelinux.org/packages

### Bash

Web site of GNU Bash

- https://www.gnu.org/software/bash/

Reference manual of GNU Bash

- https://www.gnu.org/software/bash/manual/bash.html

### Docker

Alpine version 3.23.5 in Docker Hub

- https://hub.docker.com/_/alpine?tag=3.23.5

Docker CLI

- https://docs.docker.com/reference/cli/docker/

Docker Compose CLI

- https://docs.docker.com/reference/cli/docker/compose/

Dockerfile reference

- https://docs.docker.com/reference/dockerfile/

Docker Compose file reference

- https://docs.docker.com/reference/compose-file

Dockerfile best practices

- https://docs.docker.com/build/building/best-practices/

Docker docs glossary

- https://docs.docker.com/reference/glossary/

### Linux

The manual of Linux

- https://manpages.org/

### MariaDB

Documentation of MariaDB

- https://mariadb.org/documentation/

### NGINX

Documentation of NGINX

- https://nginx.org/en/docs/

NGINX CLI

- https://nginx.org/en/docs/switches.html

NGINX variables

- https://nginx.org/en/docs/varindex.html

NGINX directives

- https://nginx.org/en/docs/dirindex.html

### PHP

Documentation of PHP

- https://www.php.net/docs.php

### The Internet

IETF Datatracker

- https://datatracker.ietf.org/

RFC 1340: Historic reference of internet numbers

- https://datatracker.ietf.org/doc/html/rfc1340

RFC 3232: Internet numbers are assigned in a database

- https://datatracker.ietf.org/doc/rfc3232/

RFC 6335 BCP 165: IANA port number provisioning

- https://datatracker.ietf.org/doc/html/rfc6335

Web site of IANA

- https://www.iana.org/

IANA port number registry

- https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml

### TLS

OpenSSL Documentation: Command "openssl req" to create a self-signed certificate

- https://docs.openssl.org/master/man1/openssl-req/

RFC 5246: Specification of TLS version 1.2

- https://datatracker.ietf.org/doc/html/rfc5246

RFC 6176: Prohibition of SSL version 2.0

- https://datatracker.ietf.org/doc/html/rfc6176

RFC 8446: Specification of TLS version 1.3

- https://datatracker.ietf.org/doc/html/rfc8446

### AI

AI was not used for any task or any part of the project.
