# Atlantis GXC Dockerfile Documentation

## Overview

This Dockerfile creates a specialized container image for running Atlantis with AWS integration, Python 3.12 support, and Docker-in-Docker capabilities. It uses a multi-stage build process to optimize image size and enhance security while providing all necessary tools for modern DevOps workflows.

Deployment tested under Amazon EKS (Kubernetes) Atlantis sBeacon
- Docker Images: `devopsxti/atlantis-gxc:latest`

## Reference

- [sBeacon](https://aehrc.csiro.au/research/cloud-native-genomics/sbeacon-making-genomic-data-sharing-future-ready/)

## Dockerfile `atlantis-gxc:20250611`

```
# syntax=docker/dockerfile:1@sha256:865e5dd094beca432e8c0a1d5e1c465db5f998dca4e439981029b3b81fb39ed5

# Base image arguments
ARG ALPINE_TAG=3.20.3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a
ARG DEBIAN_TAG=12.8-slim@sha256:ca3372ce30b03a591ec573ea975ad8b0ecaf0eb17a354416741f8001bbcae33d
ARG GOLANG_TAG=1.23.3-alpine@sha256:c694a4d291a13a9f9d94933395673494fc2cc9d4777b85df3a7e70b3492d3574

# Tool versions
ARG DEFAULT_TERRAFORM_VERSION=1.9.8
ARG DEFAULT_OPENTOFU_VERSION=1.8.6
ARG DEFAULT_CONFTEST_VERSION=0.56.0

# Stage 1: Get Artifact Atlantis
FROM ghcr.io/runatlantis/atlantis:latest@sha256:f9e0b6ff14b1313b169e4ca128a578fc719745f61114e468afab0d4cbcda575e as builder
WORKDIR /atlantis/src

# Stage 2: Install Dependencies
FROM debian:${DEBIAN_TAG} AS debian-base

# Install base packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        openssh-server \
        dumb-init \
        gnupg \
        openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 3: Setup Dependencies
FROM debian-base AS deps

# Install git-lfs
ENV GIT_LFS_VERSION=3.6.0
ENV TARGETPLATFORM=linux/amd64
WORKDIR /tmp/build

RUN case ${TARGETPLATFORM} in \
    "linux/amd64") GIT_LFS_ARCH=amd64 ;; \
    "linux/arm64") GIT_LFS_ARCH=arm64 ;; \
    "linux/arm/v7") GIT_LFS_ARCH=arm ;; \
    esac && \
    curl -L -s --output git-lfs.tar.gz "https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-${GIT_LFS_ARCH}-v${GIT_LFS_VERSION}.tar.gz" && \
    tar --strip-components=1 -xf git-lfs.tar.gz && \
    chmod +x git-lfs && \
    mv git-lfs /usr/bin/git-lfs && \
    git-lfs --version

# Install terraform binaries
ARG DEFAULT_TERRAFORM_VERSION
ENV DEFAULT_TERRAFORM_VERSION=${DEFAULT_TERRAFORM_VERSION:-1.9.8}
ARG DEFAULT_OPENTOFU_VERSION
ENV DEFAULT_OPENTOFU_VERSION=${DEFAULT_OPENTOFU_VERSION:-1.8.6}

COPY scripts/download-release.sh download-release.sh

RUN ./download-release.sh \
    "terraform" \
    "${TARGETPLATFORM}" \
    "${DEFAULT_TERRAFORM_VERSION}" \
    "1.6.6 1.7.5 1.8.5 ${DEFAULT_TERRAFORM_VERSION} 1.10.5 1.11.4" \
    && ./download-release.sh \
    "tofu" \
    "${TARGETPLATFORM}" \
    "${DEFAULT_OPENTOFU_VERSION}" \
    "${DEFAULT_OPENTOFU_VERSION}"

# Final Stage: Build sBeacon-Atlantis
FROM public.ecr.aws/sam/build-python3.12:latest-x86_64

# Switch to root for installations
USER root

# Set locale environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

# Install core dependencies and development tools
RUN dnf update -y --allowerasing && \
    dnf install -y --allowerasing \
        wget \
        curl \
        git \
        jq \
        tar \
        docker \
        gcc \
        gcc-c++ \
        make \
        cmake \
        vim \
        openssl-devel \
        libcurl-devel \
        bzip2-devel \
        libffi-devel \
        xz-devel \
        autoconf \
        intltool \
        glibc-langpack-en \
        zlib-devel \
        java-17-amazon-corretto-headless && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Setup Docker environment
RUN mkdir -p /etc/docker && \
    echo '{"storage-driver": "overlay2", "features": {"buildkit": true}}' > /etc/docker/daemon.json && \
    mkdir -p /var/lib/docker && \
    mkdir -p /var/run/docker && \
    chmod 2777 /var/run/docker

# Install Python 3.12
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz && \
    tar xzf Python-3.12.0.tgz && \
    cd Python-3.12.0 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.12.0* && \
    ln -sf /usr/local/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/local/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3

# Create system users and groups
RUN echo "docker:x:999:" >> /etc/group && \
    mkdir -p /home/atlantis && \
    echo "atlantis:x:100:100:atlantis:/home/atlantis:/bin/bash" >> /etc/passwd && \
    echo "atlantis:x:100:" >> /etc/group && \
    sed -i 's/docker:x:999:/docker:x:999:100/' /etc/group

# Ensure proper permissions for atlantis user home directory
RUN mkdir -p /home/atlantis/{.ssh,.aws,.local,.nvm,.docker,.config,.config/git,.pyenv,.npm,.pnpm,.atlantis} && \
    mkdir -p /atlantis-data && \
    mkdir -p /atlantis && \
    # Set ownership for all atlantis home directory
    chown -R 100:100 /home/atlantis && \
    chown -R 100:100 /atlantis-data && \
    chown -R 100:100 /atlantis && \
    # Set proper permissions
    chmod 755 /home/atlantis && \
    chmod 700 /home/atlantis/{.ssh,.aws} && \
    chmod 755 /home/atlantis/{.local,.config,.config/git} && \
    # Create .gitconfig with proper permissions
    touch /home/atlantis/.gitconfig && \
    chown -R 100:100 /home/atlantis/{.ssh,.aws,.local,.nvm,.docker,.config,.pyenv,.npm,.pnpm,.atlantis,.gitconfig} && \
    chmod 644 /home/atlantis/.gitconfig && \
    # Create .bash_profile and .bashrc with proper ownership
    touch /home/atlantis/.bash_profile /home/atlantis/.bashrc && \
    chown 100:100 /home/atlantis/.bash_profile /home/atlantis/.bashrc && \
    chmod 644 /home/atlantis/.bash_profile /home/atlantis/.bashrc

# Install dumb-init
RUN pip install --no-cache-dir dumb-init && \
    chmod +x /var/lang/bin/dumb-init && \
    ln -s /var/lang/bin/dumb-init /usr/local/bin/dumb-init

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.9.4/terraform_1.9.4_linux_amd64.zip && \
    unzip terraform_1.9.4_linux_amd64.zip -d /usr/bin/ && \
    rm terraform_1.9.4_linux_amd64.zip && \
    chmod +x /usr/bin/terraform

# Copy binaries and setup environment
COPY --from=builder /usr/local/bin/atlantis /usr/local/bin/atlantis
COPY --from=deps /usr/local/bin/terraform/terraform* /usr/local/bin/
COPY --from=deps /usr/local/bin/tofu/tofu* /usr/local/bin/
COPY --from=deps /usr/bin/git-lfs /usr/bin/git-lfs
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Set correct permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/atlantis && \
    chown -R 100:100 /usr/local/bin/atlantis && \
    # Ensure atlantis user can access required directories
    mkdir -p /atlantis/config && \
    chown -R 100:100 /atlantis/config

RUN mkdir -p /home/atlantis/{.ssh,.aws,.local,.nvm,.docker,.config,.pyenv,.npm,.pnpm,.atlantis} && \
    chown -R 100:100 /home/atlantis/{.ssh,.aws,.local,.nvm,.docker,.config,.pyenv,.npm,.pnpm,.atlantis}

# Copy configuration files
COPY config/docker/home /home
COPY config/docker/etc /etc
COPY config/docker/opt /opt

# Fix ownership after copying files
RUN chown -R 100:100 /home/atlantis && \
    chmod 755 /home/atlantis && \
    chmod 644 /home/atlantis/.gitconfig && \
    chmod 644 /home/atlantis/.bash_profile && \
    chmod 644 /home/atlantis/.bashrc

# Switch to atlantis user
USER 100

# Setup Node.js environment variables
ENV NODE_VERSION=20
ENV NVM_DIR="/home/atlantis/.nvm"
ENV PNPM_HOME="/home/atlantis/.local/share/pnpm"
ENV PATH="/home/atlantis/.local/bin:${PNPM_HOME}:${PATH}:/home/atlantis/.nvm/versions/node/v${NODE_VERSION}/bin"

# Install Node.js, npm, and pnpm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    npm install -g pnpm

# Install Python requirements
COPY requirements.txt ./
COPY docker-entrypoint.sh /home/atlantis
COPY scripts/atlantis-deploy /usr/local/bin/atlantis-deploy
COPY scripts/install-atlantis-deploy /usr/local/bin/install-atlantis-deploy

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Set the exposed port
EXPOSE ${ATLANTIS_PORT:-4141}

# Health check
HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost:${ATLANTIS_PORT:-4141}/healthz || exit 1

WORKDIR /home/atlantis

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["server"]
```

## Docker-Compose `docker-compose.yml`

```
version: '3.8'

#================================================================================================
# NETWORK SETUP
#================================================================================================
networks:
  atlantis_net:
    name: atlantis_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.149.0.0/16

#================================================================================================
# VOLUME SETUP
#================================================================================================
volumes:
  vol_atlantis:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS:-/opt/data/docker/atlantis}
  vol_atlantis_aws:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS_AWS:-/opt/data/docker/atlantis/aws}
  vol_atlantis_src:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS_SRC:-/opt/data/docker/atlantis/src}
  vol_atlantis_config:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS_CONFIG:-/opt/data/docker/atlantis/config}
  vol_atlantis_data:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS_DATA:-/opt/data/docker/atlantis/data}
  vol_atlantis_repos:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS_REPOS:-/opt/data/docker/atlantis/repos}
  vol_atlantis_db:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_ATLANTIS_DB:-/opt/data/docker/atlantis/db}

#================================================================================================
# SERVICES
#================================================================================================
services:
  #================================================================================================
  # POSTGRESQL DATABASE FOR ATLANTIS
  #================================================================================================
  atlantis-db:
    image: postgres:15-alpine
    container_name: ${CONTAINER_ATLANTIS_DB:-gxc_atlantis_db}
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${ATLANTIS_DB_USER:-atlantis}
      - POSTGRES_PASSWORD=${ATLANTIS_DB_PASSWORD:-atlantis_secure_password}
      - POSTGRES_DB=${ATLANTIS_DB_NAME:-atlantis}
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - /etc/localtime:/etc/localtime:ro          ## Do not use it in mac
      - /var/run/docker.sock:/var/run/docker.sock ## Do not use it in k8s
      - vol_atlantis_db:/var/lib/postgresql/data
    networks:
      atlantis_net:
        ipv4_address: ${CONTAINER_IP_ATLANTIS_DB:-172.149.149.4}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${ATLANTIS_DB_USER:-atlantis} -d ${ATLANTIS_DB_NAME:-atlantis}"]
      interval: 30s
      timeout: 10s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 1G
        reservations:
          cpus: '0.25'
          memory: 256M

  #================================================================================================
  # PORTAINER
  #================================================================================================
  portainer:
    # image: dockerframework/portainer:${PORTAINER_VERSION:-2.9}
    image: portainer/portainer-ce:${PORTAINER_VERSION:-2.30.1-alpine}
    container_name: ${CONTAINER_PORTAINER:-gxc_portainer}
    restart: unless-stopped
    ports:
      - "${PORT_PORTAINER:-5212}:9000"
    volumes:
      - /etc/localtime:/etc/localtime:ro          ## Do not use it in mac
      - /var/run/docker.sock:/var/run/docker.sock ## Do not use it in k8s
      - /opt/data/docker/portainer2.20:/data
    environment:
      - PORTAINER_TEMPLATE=generic
      - PORTAINER_VERSION=${PORTAINER_VERSION:-2.30.1-alpine}
    privileged: true
    networks:
      atlantis_net:
        ipv4_address: ${CONTAINER_IP_PORTAINER:-172.149.149.5}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://${CONTAINER_IP_PORTAINER:-172.149.149.5}:5212/api/status"]
      interval: 60s
      timeout: 5s
      retries: 5

  #================================================================================================
  # ATLANTIS TERRAFORM
  #================================================================================================
  atlantis:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        PYTHON_VERSION: 3.12
    # image: ${ATLANTIS_IMAGE:-YOUR_AWS_ACCOUNT.dkr.ecr.ap-southeast-3.amazonaws.com/gxc/atlantis-gxc}:${ATLANTIS_VERSION:-latest}
    container_name: ${CONTAINER_ATLANTIS:-gxc_atlantis}
    restart: unless-stopped
    ports:
      - "${PORT_ATLANTIS:-4141}:4141"
    volumes:
      # System mounts
      - /var/run/docker.sock:/var/run/docker.sock
      # Project data
      - vol_atlantis_src:/atlantis/src:ro
      # AWS credentials
      - ${DATA_ATLANTIS_AWS:-/opt/data/docker/atlantis/aws}/credentials:/home/atlantis/.aws/credentials:ro
      - ${DATA_ATLANTIS_AWS:-/opt/data/docker/atlantis/aws}/config:/home/atlantis/.aws/config:ro
      # Atlantis configuration
      - ${DATA_ATLANTIS:-/opt/data/docker/atlantis}/atlantis.yaml:/atlantis/atlantis.yaml:ro
      - ${DATA_ATLANTIS_CONFIG:-/opt/data/docker/atlantis/config}/repo.yaml:/atlantis/repo.yaml:ro
      # Project configuration
      - ${DATA_ATLANTIS_CONFIG:-/opt/data/docker/atlantis/config}:/atlantis/config:ro
      # Persistent data volumes
      - vol_atlantis_data:/atlantis/data
      - vol_atlantis_repos:/home/atlantis/.atlantis/repos
      # Atlantis Template
      - ${DATA_ATLANTIS:-/opt/data/docker/atlantis}/template:/home/atlantis/.atlantis/repos/template
    environment:
      # GitHub Configuration
      - ATLANTIS_GH_HOSTNAME=github.com
      - ATLANTIS_GH_USER=${ATLANTIS_GH_USER:-gxc-gh-user}
      - ATLANTIS_GH_TOKEN=${ATLANTIS_GH_TOKEN}
      - ATLANTIS_GH_WEBHOOK_SECRET=${ATLANTIS_GH_WEBHOOK_SECRET}
      # Git Configuration
      - GITHUB_USERNAME=${ATLANTIS_GH_USER:-gxc-gh-user}
      - GITHUB_TOKEN=${ATLANTIS_GH_TOKEN}
      - GIT_USER_NAME=${GIT_USER_NAME:-GXC DevOps}
      - GIT_USER_EMAIL=${ATLANTIS_GH_EMAIL:-devops@example.com}
      - CONFIG_PATH=${ATLANTIS_CONFIG_PATH:-/atlantis/config}
      # Web Configuration
      - ATLANTIS_WEB_HOSTNAME=${ATLANTIS_WEB_HOSTNAME:-atlantis.example.com}
      - ATLANTIS_PORT=${PORT_ATLANTIS:-4141}
      - ATLANTIS_ATLANTIS_URL=https://${ATLANTIS_WEB_HOSTNAME:-atlantis.example.com}
      - ATLANTIS_WEB_BASIC_AUTH=${ATLANTIS_WEB_BASIC_AUTH:-true}
      - ATLANTIS_WEB_USERNAME=${NGINX_BASIC_AUTH_USER:-gxc-admin}
      - ATLANTIS_WEB_PASSWORD=${NGINX_BASIC_AUTH_PASSWORD:-B4s1c-4uth}
      # Database Configuration
      - ATLANTIS_DB_TYPE=postgres
      - ATLANTIS_DB_HOST=${CONTAINER_IP_ATLANTIS_DB:-172.149.149.4}
      - ATLANTIS_DB_PORT=5432
      - ATLANTIS_DB_NAME=${ATLANTIS_DB_NAME:-atlantis}
      - ATLANTIS_DB_USER=${ATLANTIS_DB_USER:-atlantis}
      - ATLANTIS_DB_PASSWORD=${ATLANTIS_DB_PASSWORD:-atlantis_secure_password}
      - ATLANTIS_DB_SSL_MODE=disable
      # Data Directory
      - ATLANTIS_DATA_DIR=/atlantis/data
      # AWS Configuration
      - AWS_REGION=${AWS_REGION:-ap-southeast-3}
      - AWS_SHARED_CREDENTIALS_FILE=/home/atlantis/.aws/credentials
      - AWS_CONFIG_FILE=/home/atlantis/.aws/config
      # Project Configuration
      - ATLANTIS_CONFIG=/atlantis/atlantis.yaml
      - ATLANTIS_CONFIG_PATH=/atlantis/config
      - ATLANTIS_ALLOW_COMMANDS=version,plan,apply,unlock,approve_policies
      - ATLANTIS_REPO_ALLOWLIST=${ATLANTIS_REPO_ALLOWLIST:-github.com/GSI-Xapiens-CSIRO/*}
      - ATLANTIS_REPO_CONFIG=/atlantis/repo.yaml
      - ATLANTIS_AUTOMERGE=true
      - ATLANTIS_AUTODISCOVER_MODE=auto
      - ATLANTIS_DELETE_SOURCE_BRANCH_ON_MERGE=true
      - ATLANTIS_PARALLEL_PLAN=true
      - ATLANTIS_PARALLEL_APPLY=true
      - ATLANTIS_ABORT_ON_EXECUTION_ORDER_FAIL=true
      # Organization Structure
      - GXC_MANAGEMENT_ACCOUNT=${GXC_MANAGEMENT_ACCOUNT}
      - GXC_SECURITY_ACCOUNT=${GXC_SECURITY_ACCOUNT}
      - GXC_LOGS_ACCOUNT=${GXC_LOGS_ACCOUNT}
      - GXC_BILLING_ACCOUNT=${GXC_BILLING_ACCOUNT}
      - GXC_HUB01_ACCOUNT=${GXC_HUB01_ACCOUNT}
      - GXC_HUB02_ACCOUNT=${GXC_HUB02_ACCOUNT}
      - GXC_HUB03_ACCOUNT=${GXC_HUB03_ACCOUNT}
      - GXC_HUB04_ACCOUNT=${GXC_HUB04_ACCOUNT}
      - GXC_HUB05_ACCOUNT=${GXC_HUB05_ACCOUNT}
      - GXC_UAT01_ACCOUNT=${GXC_UAT01_ACCOUNT}
      - GXC_UAT02_ACCOUNT=${GXC_UAT02_ACCOUNT}
      - GXC_UAT03_ACCOUNT=${GXC_UAT03_ACCOUNT}
      - GXC_UAT04_ACCOUNT=${GXC_UAT04_ACCOUNT}
      - GXC_UAT05_ACCOUNT=${GXC_UAT05_ACCOUNT}
      # Other Configuration
      - DEFAULT_CONFTEST_VERSION=${CONFTEST_VERSION:-0.56.0}
      - TZ=Asia/Jakarta
      - PYTHONPATH=/usr/local/lib/python3.12/site-packages
    user: "100:100" # atlantis:atlantis
    privileged: true
    depends_on:
      atlantis-db:
        condition: service_healthy
    networks:
      atlantis_net:
        ipv4_address: ${CONTAINER_IP_ATLANTIS:-172.149.149.6}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://${CONTAINER_IP_ATLANTIS:-172.149.149.6}:4141/healthz"]
      interval: 60s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '2.50'
          memory: 10G
        reservations:
          cpus: '0.30'
          memory: 256M
    labels:
      app: atlantis
      env: staging
      team: devops

  #================================================================================================
  # NGINX ATLANTIS
  #================================================================================================
  nginx:
    image: nginx:1.25.3-alpine
    container_name: ${CONTAINER_NGINX:-gxc_nginx}
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ${DATA_NGINX:-/opt/data/docker/nginx}/conf.d:/etc/nginx/conf.d
      - ${DATA_NGINX:-/opt/data/docker/nginx}/ssl:/etc/nginx/ssl
      - ${DATA_NGINX:-/opt/data/docker/nginx}/logs:/var/log/nginx
      - ${DATA_NGINX:-/opt/data/docker/nginx}/auth:/etc/nginx/auth
    environment:
      - NGINX_HOST=${ATLANTIS_WEB_HOSTNAME:-atlantis.example.com}
      - NGINX_PORT=80
      # Basic Auth Configuration
      - NGINX_BASIC_AUTH_USER=${NGINX_BASIC_AUTH_USER:-gxc-admin}
      - NGINX_BASIC_AUTH_PASSWORD=${NGINX_BASIC_AUTH_PASSWORD:-B4s1c-4uth}
    depends_on:
      - atlantis
    networks:
      atlantis_net:
        ipv4_address: ${CONTAINER_IP_NGINX:-172.149.149.7}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://${CONTAINER_IP_NGINX:-172.149.149.7}/healthz"]
      interval: 60s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '1.50'
          memory: 2G
        reservations:
          cpus: '0.10'
          memory: 128M
    labels:
      app: nginx
      env: staging
      team: devops
```

## Docker Entrypoint `docker-entrypoint.sh`

```
#!/usr/bin/env -S dumb-init --single-child /bin/bash

set -euo pipefail

# Function to check if we have docker socket access
check_docker_socket() {
    if [ -S /var/run/docker.sock ]; then
        # Test docker socket access
        if docker info >/dev/null 2>&1; then
            echo " Docker socket is accessible and working."
            return 0
        else
            echo " Docker socket exists but not accessible."
            return 1
        fi
    else
        echo " WARNING: Docker socket not accessible. Some features may be limited."
        return 1
    fi
}

# For root user
if [ "$(id -u)" = "0" ]; then
    export NVM_DIR="/root/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export PNPM_HOME="/root/.local/share/pnpm"
else
    # For atlantis user
    export NVM_DIR="/home/atlantis/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export PNPM_HOME="/home/atlantis/.local/share/pnpm"
fi
export PATH="${PNPM_HOME}:${PATH}"

# For root user
if [ "$(id -u)" = "0" ]; then
    export HOME_BASE="/root"
else
    export HOME_BASE="/home/atlantis"
fi

[ -f $HOME_BASE/.bash_profile ] && source $HOME_BASE/.bash_profile
[ -f $HOME_BASE/.bashrc ] && source $HOME_BASE/.bashrc

# If we're trying to run atlantis directly with some arguments, then
# pass them to atlantis.
if [ "${1:0:1}" = '-' ]; then
    set -- atlantis "$@"
fi

# Check if running a atlantis subcommand and prepend atlantis if needed
if [ $# -gt 0 ]; then
    case "$1" in
        server|version|testdrive)
            # These are valid atlantis subcommands, prepend atlantis
            set -- atlantis "$@"
            ;;
        atlantis)
            # Already has atlantis, leave as is
            ;;
        *)
            # Check if it's a valid atlantis subcommand
            if atlantis help "$1" 2>&1 | grep -q "atlantis $1"; then
                set -- atlantis "$@"
            fi
            ;;
    esac
fi

# Create user in /etc/passwd if running without user
if ! whoami &> /dev/null; then
    if [ -w /etc/passwd ]; then
        echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:/home/atlantis:/sbin/nologin" >> /etc/passwd
    fi
fi

# Check for scripts in /docker-entrypoint.d/
if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "/docker-entrypoint.d/ is not empty, executing scripts"
    find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo "Executing $f"
                    "$f"
                else
                    echo "Ignoring $f, not executable"
                fi
                ;;
            *) echo "Ignoring $f";;
        esac
    done
else
    echo "No files found in /docker-entrypoint.d/, skipping"
fi

# Verify environment
echo "Verifying environment..."
echo ""
echo "==============================================================================="
echo " Atlantis Server: "
echo "   $(atlantis version) "
echo "==============================================================================="
echo " Node version: $(node --version 2>/dev/null || echo 'Not available')"
echo " NPM version: $(npm --version 2>/dev/null || echo 'Not available')"
echo " PNPM version: $(pnpm --version 2>/dev/null || echo 'Not available')"
echo " Python version: $(python --version 2>&1 || echo 'Not available')"
echo " Terraform version: $(terraform --version 2>/dev/null | head -n1 || echo 'Not available')"
if check_docker_socket; then
    echo " -> Docker version: $(docker --version 2>/dev/null || echo 'Not available')"
else
    echo " -> Docker version: Not available (no socket access)"
fi
echo "==============================================================================="

# Debug: Show what we're about to execute
echo "🔍 About to execute: $*"

# Execute the main command
exec "$@"
```

## Environment Variable (.env)

```
# Atlantis Environment Configuration

#================================================================================================
# CORE CONFIGURATION
#================================================================================================
# Environment
TZ=Asia/Jakarta
PYTHONPATH=/usr/local/lib/python3.12/site-packages

#================================================================================================
# VOLUME CONFIGURATION
#================================================================================================
# Volume Driver
VOLUMES_DRIVER=local

# Base Data Paths
DATA_PATH=/opt/data/docker

# Data directories
DATA_ATLANTIS=/opt/data/docker/atlantis
DATA_ATLANTIS_AWS=/opt/data/docker/atlantis/aws
DATA_ATLANTIS_SRC=/opt/data/docker/atlantis/src

# Using container binding volume path
DATA_ATLANTIS_CONFIG=/opt/data/docker/atlantis/config

#================================================================================================
# CONTAINER CONFIGURATION
#================================================================================================
# Portainer Container
CONTAINER_PORTAINER=gxc_portainer
CONTAINER_IP_PORTAINER=172.149.149.5
PORT_PORTAINER=5212

# Atlantis Container
CONTAINER_ATLANTIS=gxc_atlantis
CONTAINER_IP_ATLANTIS=172.149.149.6
CONTAINER_IP_ATLANTIS_DB=172.149.149.4
PORT_ATLANTIS=4141

# Nginx Container
CONTAINER_NGINX=gxc_nginx
DATA_NGINX=/opt/data/docker/nginx
CONTAINER_IP_NGINX=172.149.149.7

#================================================================================================
# IMAGE CONFIGURATION
#================================================================================================
# Atlantis
ATLANTIS_VERSION=latest
ATLANTIS_IMAGE=devopsxti/atlantis-gxc:latest

# Version tags
PORTAINER_VERSION=2.20.3-alpine
PORTAINER_TEMPLATE=generic

#================================================================================================
# GITHUB CONFIGURATION
#================================================================================================
ATLANTIS_GH_HOSTNAME=github.com
ATLANTIS_GH_USER=gxc-gh-user
ATLANTIS_GH_EMAIL=devops@example.com
ATLANTIS_WEB_HOSTNAME=atlantis.example.com
ATLANTIS_REPO_ALLOWLIST=github.com/GSI-Xapiens-CSIRO/BGSI-GeneticAnalysisSupportPlatformIndonesia-GASPI/*
ATLANTIS_REPO_CONFIG=/atlantis/repo.yaml
ATLANTIS_CONFIG_PATH=/atlantis/config
GIT_USER_NAME="GXC DevOps"

# Security Secrets (DO NOT COMMIT - Set these in .env local)
# ATLANTIS_GH_TOKEN=your-github-token
# ATLANTIS_GH_WEBHOOK_SECRET=your-webhook-secret

#================================================================================================
# AWS CONFIGURATION
#================================================================================================
# Region
AWS_REGION=ap-southeast-3

# Account Structure (replace with your account IDs)
GXC_MANAGEMENT_ACCOUNT=
GXC_SECURITY_ACCOUNT=
GXC_LOGS_ACCOUNT=
GXC_BILLING_ACCOUNT=
GXC_HUB01_ACCOUNT=
GXC_HUB02_ACCOUNT=
GXC_HUB03_ACCOUNT=
GXC_HUB04_ACCOUNT=
GXC_HUB05_ACCOUNT=
GXC_UAT01_ACCOUNT=
GXC_UAT02_ACCOUNT=
GXC_UAT03_ACCOUNT=
GXC_UAT04_ACCOUNT=
GXC_UAT05_ACCOUNT=

#================================================================================================
# SECURITY CONFIGURATION
#================================================================================================
# Basic Auth
NGINX_BASIC_AUTH_USER=gxc-admin
NGINX_BASIC_AUTH_PASS=B4s1c-4uth

#================================================================================================
# TOOL VERSIONS
#================================================================================================
CONFTEST_VERSION=0.56.0
PYTHON_VERSION=3.12
NODE_VERSION=20

#================================================================================================
# RESOURCE LIMITS
#================================================================================================
# Atlantis Resources
ATLANTIS_CPU_LIMIT=2048m
ATLANTIS_MEMORY_LIMIT=8Gi
ATLANTIS_CPU_REQUEST=300m
ATLANTIS_MEMORY_REQUEST=256Mi

# Nginx Resources
NGINX_CPU_LIMIT=300m
NGINX_MEMORY_LIMIT=512Mi
NGINX_CPU_REQUEST=100m
NGINX_MEMORY_REQUEST=128Mi

#================================================================================================
# HEALTH CHECK CONFIGURATION
#================================================================================================
HEALTH_CHECK_INTERVAL=60s
HEALTH_CHECK_TIMEOUT=5s
HEALTH_CHECK_RETRIES=5

#================================================================================================
# WORKFLOW CONFIGURATION
#================================================================================================
# Atlantis Settings
ATLANTIS_AUTOMERGE=true
ATLANTIS_PARALLEL_PLAN=true
ATLANTIS_PARALLEL_APPLY=true
ATLANTIS_ALLOW_COMMANDS=version,plan,apply,unlock,approve_policies

#================================================================================================
# ATLANTIS DATABASE CONFIGURATION
#================================================================================================
ATLANTIS_DB_TYPE=postgres
ATLANTIS_DB_HOST=172.149.149.4
ATLANTIS_DB_PORT=5432
ATLANTIS_DB_NAME=atlantis
ATLANTIS_DB_USER=atlantis
ATLANTIS_DB_PASSWORD=atlantis_secure_password
ATLANTIS_DB_SSL_MODE=disable

#================================================================================================
# BACKUP CONFIGURATION
#================================================================================================
BACKUP_RETENTION_DAYS=30
BACKUP_PATH=/backup/atlantis
```

## Package Javascript `package.json`

```
{
  "license": "Apache-2.0",
  "type": "module",
  "devDependencies": {
    "@playwright/test": "^1.44.0",
    "@types/node": "^20.12.12",
    "@vueuse/core": "^10.9.0",
    "markdown-it-footnote": "^4.0.0",
    "markdownlint-cli": "^0.40.0",
    "mermaid": "^10.9.1",
    "sitemap-ts": "^1.7.3",
    "vitepress": "^1.2.3",
    "vitepress-plugin-mermaid": "^2.0.16",
    "vue": "^3.4.27"
  },
  "scripts": {
    "website:dev": "vitepress dev --host localhost --port 8080 runatlantis.io",
    "website:lint": "markdownlint runatlantis.io",
    "website:lint-fix": "markdownlint --fix runatlantis.io",
    "website:build": "vitepress build runatlantis.io",
    "e2e": "playwright test"
  }
}
```

---

## Copyright

- Author: **DevOps Engineer**
- Vendor: **Xapiens Technology Indonesia (@xapiens.id)**
- License: **Apache v2**
