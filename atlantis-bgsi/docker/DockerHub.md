# Atlantis BGSI Dockerfile Documentation

## Overview

This Dockerfile creates a specialized container image for running Atlantis with AWS integration, Python 3.12 support, and Docker-in-Docker capabilities. It uses a multi-stage build process to optimize image size and enhance security while providing all necessary tools for modern DevOps workflows.

Deployment tested under Amazon EKS (Kubernetes) Atlantis sBeacon
- Docker Images: `devopsxti/atlantis-bgsi:latest`

## Reference

- [sBeacon](https://aehrc.csiro.au/research/cloud-native-genomics/sbeacon-making-genomic-data-sharing-future-ready/)

## Dockerfile `atlantis-bgsi:20250913`

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
ARG DEFAULT_TERRAGRUNT_VERSION=0.70.4

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

# Install terraform, tofu, and terragrunt binaries
ARG DEFAULT_TERRAFORM_VERSION
ENV DEFAULT_TERRAFORM_VERSION=${DEFAULT_TERRAFORM_VERSION:-1.9.8}
ARG DEFAULT_OPENTOFU_VERSION
ENV DEFAULT_OPENTOFU_VERSION=${DEFAULT_OPENTOFU_VERSION:-1.8.6}
ARG DEFAULT_TERRAGRUNT_VERSION
ENV DEFAULT_TERRAGRUNT_VERSION=${DEFAULT_TERRAGRUNT_VERSION:-0.70.4}

COPY scripts/download-release.sh download-release.sh

# Install Terraform
RUN ./download-release.sh \
    "terraform" \
    "${TARGETPLATFORM}" \
    "${DEFAULT_TERRAFORM_VERSION}" \
    "1.6.6 1.7.5 1.8.5 ${DEFAULT_TERRAFORM_VERSION} 1.10.5 1.11.4"

# Install OpenTofu
RUN ./download-release.sh \
    "tofu" \
    "${TARGETPLATFORM}" \
    "${DEFAULT_OPENTOFU_VERSION}" \
    "${DEFAULT_OPENTOFU_VERSION}"

# Install Terragrunt (compatible with Terraform 1.9.8+)
RUN ./download-release.sh \
    "terragrunt" \
    "${TARGETPLATFORM}" \
    "${DEFAULT_TERRAGRUNT_VERSION}" \
    "${DEFAULT_TERRAGRUNT_VERSION}"

# Final Stage: Build Atlantis
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

# Install AWS CLI v2
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
#     unzip awscliv2.zip && \
#     ./aws/install && \
#     rm -rf aws awscliv2.zip

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
RUN mkdir -p /home/atlantis/.ssh /home/atlantis/.aws /home/atlantis/.local /home/atlantis/.nvm \
             /home/atlantis/.docker /home/atlantis/.config /home/atlantis/.config/git \
             /home/atlantis/.pyenv /home/atlantis/.npm /home/atlantis/.pnpm /home/atlantis/.atlantis && \
    mkdir -p /atlantis-data && \
    mkdir -p /atlantis && \
    # Set ownership for all atlantis home directory
    chown -R 100:100 /home/atlantis && \
    chown -R 100:100 /atlantis-data && \
    chown -R 100:100 /atlantis && \
    # Set proper permissions
    chmod 755 /home/atlantis && \
    chmod 700 /home/atlantis/.ssh /home/atlantis/.aws && \
    chmod 755 /home/atlantis/.local /home/atlantis/.config /home/atlantis/.config/git && \
    # Create .gitconfig with proper permissions
    touch /home/atlantis/.gitconfig && \
    chown 100:100 /home/atlantis/.gitconfig && \
    chmod 644 /home/atlantis/.gitconfig && \
    # Create .bash_profile and .bashrc with proper ownership
    touch /home/atlantis/.bash_profile /home/atlantis/.bashrc && \
    chown 100:100 /home/atlantis/.bash_profile /home/atlantis/.bashrc && \
    chmod 644 /home/atlantis/.bash_profile /home/atlantis/.bashrc

# Install dumb-init
RUN pip install --no-cache-dir dumb-init && \
    chmod +x /var/lang/bin/dumb-init && \
    ln -s /var/lang/bin/dumb-init /usr/local/bin/dumb-init

# Copy binaries and setup environment
COPY --from=builder /usr/local/bin/atlantis /usr/local/bin/atlantis
COPY --from=deps /usr/local/bin/terraform/terraform* /usr/local/bin/
COPY --from=deps /usr/local/bin/tofu/tofu* /usr/local/bin/
COPY --from=deps /usr/local/bin/terragrunt/terragrunt* /usr/local/bin/
COPY --from=deps /usr/bin/git-lfs /usr/bin/git-lfs
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Set correct permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/atlantis && \
    chown -R 100:100 /usr/local/bin/atlantis && \
    chmod +x /usr/local/bin/terragrunt* && \
    # Ensure atlantis user can access required directories
    mkdir -p /atlantis/config && \
    chown -R 100:100 /atlantis/config

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

# Install Python requirements
COPY requirements.txt ./
RUN python3.12 -m pip install --upgrade pip
RUN pip install -r requirements.txt

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

# Copy atlantis-deploy & sonar-scan script
COPY docker-entrypoint.sh /home/atlantis
COPY scripts/atlantis-deploy /usr/local/bin/atlantis-deploy
COPY scripts/install-atlantis-deploy /usr/local/bin/install-atlantis-deploy
# COPY scripts/sonar-scan /usr/local/bin/sonar-scan
# COPY scripts/sonarqube.env.example /usr/local/bin/sonarqube.env

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
  vol_sonar_data:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_SONAR:-/opt/data/docker/sonarqube}
  vol_sonar_reports:
    driver: ${VOLUMES_DRIVER:-local}
    driver_opts:
      o: bind
      type: none
      device: ${DATA_SONAR_REPORTS:-/opt/data/docker/sonarqube/reports}

#================================================================================================
# SERVICES
#================================================================================================
services:
  #================================================================================================
  # POSTGRESQL DATABASE FOR ATLANTIS
  #================================================================================================
  atlantis-db:
    image: postgres:15-alpine
    container_name: ${CONTAINER_ATLANTIS_DB:-bgsi_atlantis_db}
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${ATLANTIS_DB_USER:-postgres}
      - POSTGRES_PASSWORD=${ATLANTIS_DB_PASSWORD}
      - POSTGRES_DB=${ATLANTIS_DB_NAME:-bgsi_atlantis_db}
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - /etc/localtime:/etc/localtime:ro          ## Do not use it in mac
      - /var/run/docker.sock:/var/run/docker.sock ## Do not use it in k8s
      - vol_atlantis_db:/var/lib/postgresql/data
    networks:
      atlantis_net:
        ipv4_address: ${CONTAINER_IP_ATLANTIS_DB:-172.150.150.4}
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
    image: portainer/portainer-ce:${PORTAINER_VERSION:-2.30.1-alpine}
    container_name: ${CONTAINER_PORTAINER:-bgsi_portainer}
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
        ipv4_address: ${CONTAINER_IP_PORTAINER:-172.150.150.5}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://${CONTAINER_IP_PORTAINER:-172.150.150.5}:5212/api/status"]
      interval: 60s
      timeout: 5s
      retries: 5

  #================================================================================================
  # ATLANTIS TERRAFORM
  #================================================================================================
  atlantis:
    # build:
    #   context: .
    #   dockerfile: Dockerfile
    #   args:
    #     PYTHON_VERSION: 3.12
    # image: ${ATLANTIS_IMAGE:-YOUR_AWS_ACCOUNT.dkr.ecr.ap-southeast-3.amazonaws.com/bgsi/atlantis-bgsi}:${ATLANTIS_VERSION:-latest}
    # image: devopsxti/atlantis-bgsi:latest
    image: devopsxti/atlantis-bgsi:2.5.0
    container_name: ${CONTAINER_ATLANTIS:-bgsi_atlantis}
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
      # SonarQube reports (shared volume)
      - vol_sonar_reports:/opt/sonar-reports
    environment:
      # GitHub Configuration
      - ATLANTIS_GH_HOSTNAME=github.com
      - ATLANTIS_GH_USER=${ATLANTIS_GH_USER:-bgsi-gh-user}
      - ATLANTIS_GH_TOKEN=${ATLANTIS_GH_TOKEN}
      - ATLANTIS_GH_WEBHOOK_SECRET=${ATLANTIS_GH_WEBHOOK_SECRET}
      # Git Configuration
      - GITHUB_USERNAME=${ATLANTIS_GH_USER:-bgsi-gh-user}
      - GITHUB_TOKEN=${ATLANTIS_GH_TOKEN}
      - GIT_USER_NAME=${GIT_USER_NAME:-BGSI DevOps}
      - GIT_USER_EMAIL=${ATLANTIS_GH_EMAIL:-devops@example.com}
      - CONFIG_PATH=${ATLANTIS_CONFIG_PATH:-/atlantis/config}
      # Web Configuration
      - ATLANTIS_WEB_HOSTNAME=${ATLANTIS_WEB_HOSTNAME:-atlantis.example.com}
      - ATLANTIS_WEB_BASIC_AUTH=true
      - ATLANTIS_PORT=${PORT_ATLANTIS:-4141}
      - ATLANTIS_ATLANTIS_URL=https://${ATLANTIS_WEB_HOSTNAME:-atlantis.example.com}
      - ATLANTIS_WEB_BASIC_AUTH=${ATLANTIS_WEB_BASIC_AUTH:-true}
      - ATLANTIS_WEB_USERNAME=${NGINX_BASIC_AUTH_USER:-bgsi-admin}
      - ATLANTIS_WEB_PASSWORD=${NGINX_BASIC_AUTH_PASSWORD:-B4s1c-4uth}
      # Database Configuration
      - ATLANTIS_DB_TYPE=postgres
      - ATLANTIS_DB_HOST=${CONTAINER_IP_ATLANTIS_DB:-172.150.150.4}
      - ATLANTIS_DB_PORT=5432
      - ATLANTIS_DB_NAME=${ATLANTIS_DB_NAME:-bgsi_atlantis_db}
      - ATLANTIS_DB_USER=${ATLANTIS_DB_USER:-postgres}
      - ATLANTIS_DB_PASSWORD=${ATLANTIS_DB_PASSWORD}
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
      - ATLANTIS_REPO_ALLOWLIST=${ATLANTIS_REPO_ALLOWLIST:-github.com/bgsi-id/*}
      - ATLANTIS_REPO_CONFIG=/atlantis/repo.yaml
      - ATLANTIS_AUTOMERGE=true
      - ATLANTIS_AUTODISCOVER_MODE=auto
      - ATLANTIS_DELETE_SOURCE_BRANCH_ON_MERGE=true
      - ATLANTIS_PARALLEL_PLAN=true
      - ATLANTIS_PARALLEL_APPLY=true
      - ATLANTIS_ABORT_ON_EXECUTION_ORDER_FAIL=true
      - ATLANTIS_CHECKOUT_STRATEGY=merge
      - ATLANTIS_CHECKOUT_DEPTH=10  # Number of commit hash
      - ATLANTIS_HIDE_PREV_PLAN_COMMENTS=true
      - ATLANTIS_TEST_TIMEOUT=${ATLANTIS_TEST_TIMEOUT:-600}
      - ATLANTIS_LOG_LEVEL=warn
      #================================================================================================
      # SONARQUBE INTEGRATION CONFIGURATION
      #================================================================================================
      # Main SonarQube Controls
      - ENABLE_SONARQUBE=${ENABLE_SONARQUBE:-true}
      - SONARQUBE_REQUIRED=${SONARQUBE_REQUIRED:-false}
      - SONARQUBE_QUALITY_GATE_REQUIRED=${SONARQUBE_QUALITY_GATE_REQUIRED:-false}
      # SonarQube Server Configuration
      - SONAR_HOST_URL=${SONAR_HOST_URL:-http://sonarqube-web:9000}
      - SONAR_SCANNER_IMAGE=${SONAR_SCANNER_IMAGE:-sonarsource/sonar-scanner-cli:latest}
      - SONAR_ANALYSIS_TIMEOUT=${SONAR_ANALYSIS_TIMEOUT:-600}
      # Internal SonarQube Service (when using local SonarQube)
      - SONAR_INTERNAL_URL=${SONAR_INTERNAL_URL:-http://sonarqube-local:9000}
      - SONAR_SCANNER_CONTAINER=${SONAR_SCANNER_CONTAINER:-bgsi_sonar_scanner}
      # Security and Testing Controls
      - SCRIPT_RUN_TEST=${SCRIPT_RUN_TEST:-true}
      - SCRIPT_RUN_SONAR=${SCRIPT_RUN_SONAR:-true}
      - SONAR_TOKEN_RSCM=${SONAR_TOKEN_RSCM}
      - SONAR_TOKEN_RSPON=${SONAR_TOKEN_RSPON}
      - SONAR_TOKEN_SARDJITO=${SONAR_TOKEN_SARDJITO}
      - SONAR_TOKEN_RSNGOERAH=${SONAR_TOKEN_RSNGOERAH}
      - SONAR_TOKEN_RSJPD=${SONAR_TOKEN_RSJPD}
      - SONAR_TOKEN_RSCM-UAT=${SONAR_TOKEN_RSCM-UAT}
      - SONAR_TOKEN_RSPON-UAT=${SONAR_TOKEN_RSPON-UAT}
      - SONAR_TOKEN_SARDJITO-UAT=${SONAR_TOKEN_SARDJITO-UAT}
      - SONAR_TOKEN_RSNGOERAH-UAT=${SONAR_TOKEN_RSNGOERAH-UAT}
      - SONAR_TOKEN_RSJPD-UAT=${SONAR_TOKEN_RSJPD-UAT}
      - SONAR_PROJECT_KEY_RSCM=${SONAR_PROJECT_KEY_RSCM:-bgsi-cicd-gaspi-rscm}
      - SONAR_PROJECT_KEY_RSPON=${SONAR_PROJECT_KEY_RSPON:-bgsi-cicd-gaspi-rspon}
      - SONAR_PROJECT_KEY_SARDJITO=${SONAR_PROJECT_KEY_SARDJITO:-bgsi-cicd-gaspi-sardjito}
      - SONAR_PROJECT_KEY_RSNGOERAH=${SONAR_PROJECT_KEY_RSNGOERAH:-bgsi-cicd-gaspi-rsngoerah}
      - SONAR_PROJECT_KEY_RSJPD=${SONAR_PROJECT_KEY_RSJPD:-bgsi-cicd-gaspi-rsjpd}
      - SONAR_PROJECT_KEY_RSCM-UAT=${SONAR_PROJECT_KEY_RSCM-UAT:-bgsi-cicd-gaspi-rscm-uat}
      - SONAR_PROJECT_KEY_RSPON-UAT=${SONAR_PROJECT_KEY_RSPON-UAT:-bgsi-cicd-gaspi-rspon-uat}
      - SONAR_PROJECT_KEY_SARDJITO-UAT=${SONAR_PROJECT_KEY_SARDJITO-UAT:-bgsi-cicd-gaspi-sardjito-uat}
      - SONAR_PROJECT_KEY_RSNGOERAH-UAT=${SONAR_PROJECT_KEY_RSNGOERAH-UAT:-bgsi-cicd-gaspi-rsngoerah-uat}
      - SONAR_PROJECT_KEY_RSJPD-UAT=${SONAR_PROJECT_KEY_RSJPD-UAT:-bgsi-cicd-gaspi-rsjpd-uat}
      #================================================================================================
      # AWS ACCOUNT
      #================================================================================================
      # Organization Structure
      - BGSI_MANAGEMENT_ACCOUNT=${BGSI_MANAGEMENT_ACCOUNT}
      - BGSI_SECURITY_ACCOUNT=${BGSI_SECURITY_ACCOUNT}
      - BGSI_LOGS_ACCOUNT=${BGSI_LOGS_ACCOUNT}
      - BGSI_BILLING_ACCOUNT=${BGSI_BILLING_ACCOUNT}
      - BGSI_RSCM_ACCOUNT=${BGSI_RSCM_ACCOUNT}
      - BGSI_RSPON_ACCOUNT=${BGSI_RSPON_ACCOUNT}
      - BGSI_SARDJITO_ACCOUNT=${BGSI_SARDJITO_ACCOUNT}
      - BGSI_RSNGOERAH_ACCOUNT=${BGSI_RSNGOERAH_ACCOUNT}
      - BGSI_RSJPD_ACCOUNT=${BGSI_RSJPD_ACCOUNT}
      - BGSI_RSCM-UAT_ACCOUNT=${BGSI_RSCM-UAT_ACCOUNT}
      - BGSI_RSPON-UAT_ACCOUNT=${BGSI_RSPON-UAT_ACCOUNT}
      - BGSI_SARDJITO-UAT_ACCOUNT=${BGSI_SARDJITO-UAT_ACCOUNT}
      - BGSI_RSNGOERAH-UAT_ACCOUNT=${BGSI_RSNGOERAH-UAT_ACCOUNT}
      - BGSI_RSJPD-UAT_ACCOUNT=${BGSI_RSJPD-UAT_ACCOUNT}
      #================================================================================================
      # OTHERS
      #================================================================================================
      # Other Configuration
      - ENABLE_SECURITY_AUDIT=true
      - LOG_LEVEL=INFO
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
        ipv4_address: ${CONTAINER_IP_ATLANTIS:-172.150.150.6}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://${CONTAINER_IP_ATLANTIS:-172.150.150.6}:4141/healthz"]
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
    container_name: ${CONTAINER_NGINX:-bgsi_nginx}
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
      - NGINX_BASIC_AUTH_USER=${NGINX_BASIC_AUTH_USER:-bgsi-admin}
      - NGINX_BASIC_AUTH_PASSWORD=${NGINX_BASIC_AUTH_PASSWORD:-B4s1c-4uth}
    depends_on:
      - atlantis
    networks:
      atlantis_net:
        ipv4_address: ${CONTAINER_IP_NGINX:-172.150.150.7}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://${CONTAINER_IP_NGINX:-172.150.150.7}/healthz"]
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
DATA_POSTGRESQL=/opt/data/docker/postgresql/data

#================================================================================================
# CONTAINER CONFIGURATION
#================================================================================================
# Portainer Container
CONTAINER_PORTAINER=bgsi_portainer
CONTAINER_IP_PORTAINER=172.150.150.5
PORT_PORTAINER=5212

# Atlantis Container
CONTAINER_ATLANTIS=bgsi_atlantis
CONTAINER_IP_ATLANTIS=172.150.150.6
CONTAINER_IP_ATLANTIS_DB=172.150.150.4
PORT_ATLANTIS=4141

# Nginx Container
CONTAINER_NGINX=bgsi_nginx
DATA_NGINX=/opt/data/docker/nginx
CONTAINER_IP_NGINX=172.150.150.7

# PostgreSQL Container
CONTAINER_POSTGRESQL=bgsi_postgresql
CONTAINER_IP_POSTGRESQL=172.150.150.8
# PostgreSQL Settings
POSTGRES_USER=sonar
POSTGRES_PASSWORD=sonar
POSTGRES_DB=sonar

#================================================================================================
# IMAGE CONFIGURATION
#================================================================================================
# Atlantis
ATLANTIS_VERSION=latest
# ATLANTIS_IMAGE=463470956521.dkr.ecr.ap-southeast-3.amazonaws.com/bgsi/atlantis-bgsi
ATLANTIS_IMAGE=devopsxti/atlantis-bgsi:latest

# Version tags
PORTAINER_VERSION=2.30.1-alpine
PORTAINER_TEMPLATE=generic
POSTGRES_VERSION=15.4-alpine
SONARQUBE_VERSION=10.3-community
NGINX_VERSION=1.25.3-alpine


#================================================================================================
# GITHUB CONFIGURATION
#================================================================================================
ATLANTIS_GH_HOSTNAME=github.com
ATLANTIS_GH_USER=bgsi-gh-user
ATLANTIS_GH_EMAIL=devops@example.com
ATLANTIS_WEB_HOSTNAME=atlantis.example.com
ATLANTIS_WEB_BASIC_AUTH=true
ATLANTIS_REPO_ALLOWLIST=github.com/bgsi-id/*/*
ATLANTIS_REPO_CONFIG=/atlantis/repo.yaml
ATLANTIS_CONFIG_PATH=/atlantis/config
ATLANTIS_CHECKOUT_STRATEGY=merge
ATLANTIS_CHECKOUT_DEPTH=10  # Number of commit hash
GIT_USER_NAME="BGSI DevOps"

ATLANTIS_HIDE_PREV_PLAN_COMMENTS=true
ATLANTIS_TEST_TIMEOUT=600
ATLANTIS_LOG_LEVEL=warn
ENABLE_SECURITY_AUDIT=true
LOG_LEVEL=INFO

# Security Secrets (DO NOT COMMIT - Set these in .env local)
# ATLANTIS_GH_TOKEN=your-github-token
# ATLANTIS_GH_WEBHOOK_SECRET=your-webhook-secret

#================================================================================================
# AWS CONFIGURATION
#================================================================================================
# Region
AWS_REGION=ap-southeast-3

# Account Structure (replace with your account IDs)
BGSI_MANAGEMENT_ACCOUNT=
BGSI_SECURITY_ACCOUNT=
BGSI_LOGS_ACCOUNT=
BGSI_BILLING_ACCOUNT=
BGSI_RSCM_ACCOUNT=
BGSI_RSPON_ACCOUNT=
BGSI_SARDJITO_ACCOUNT=
BGSI_RSNGOERAH_ACCOUNT=
BGSI_RSJPD_ACCOUNT=
BGSI_RSCM-UAT_ACCOUNT=
BGSI_RSPON-UAT_ACCOUNT=
BGSI_SARDJITO-UAT_ACCOUNT=
BGSI_RSNGOERAH-UAT_ACCOUNT=
BGSI_RSJPD-UAT_ACCOUNT=

#================================================================================================
# SECURITY CONFIGURATION
#================================================================================================
# Basic Auth
NGINX_BASIC_AUTH_USER=bgsi-admin
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
ATLANTIS_DB_HOST=172.150.150.4
ATLANTIS_DB_PORT=5432
ATLANTIS_DB_NAME=bgsi_atlantis_db
ATLANTIS_DB_USER=postgres
ATLANTIS_DB_PASSWORD=
ATLANTIS_DB_SSL_MODE=disable

#================================================================================================
# BACKUP CONFIGURATION
#================================================================================================
BACKUP_RETENTION_DAYS=30
BACKUP_PATH=/backup/atlantis

# =============================================================================
# SONARQUBE CONFIGURATION
# =============================================================================
# Main Controls
ENABLE_SONARQUBE=true                          # true/false - Master toggle
SONARQUBE_REQUIRED=false                       # true/false - Fail pipeline if SonarQube fails
SONARQUBE_QUALITY_GATE_REQUIRED=false          # true/false - Fail on quality gate failure

# SonarQube Server
SONAR_HOST_URL=http://sonarqube_web:9000
SONAR_TOKEN=__sonarqube_token__
SONAR_TOKEN_RSCM=__sonarqube_token__
SONAR_TOKEN_RSPON=__sonarqube_token__
SONAR_TOKEN_SARDJITO=__sonarqube_token__
SONAR_TOKEN_RSNGOERAH=__sonarqube_token__
SONAR_TOKEN_RSJPD=__sonarqube_token__
SONAR_TOKEN_RSCM-UAT=__sonarqube_token__
SONAR_TOKEN_RSPON-UAT=__sonarqube_token__
SONAR_TOKEN_SARDJITO-UAT=__sonarqube_token__
SONAR_TOKEN_RSNGOERAH-UAT=__sonarqube_token__
SONAR_TOKEN_RSJPD-UAT=__sonarqube_token__
SONAR_PROJECT_KEY=bgsi-cicd-gaspi
SONAR_PROJECT_KEY_RSCM=bgsi-cicd-gaspi-rscm
SONAR_PROJECT_KEY_RSPON=bgsi-cicd-gaspi-rspon
SONAR_PROJECT_KEY_SARDJITO=bgsi-cicd-gaspi-sardjito
SONAR_PROJECT_KEY_RSNGOERAH=bgsi-cicd-gaspi-rsngoerah
SONAR_PROJECT_KEY_RSJPD=bgsi-cicd-gaspi-rsjpd
SONAR_PROJECT_KEY_RSCM-UAT=bgsi-cicd-gaspi-rscm-uat
SONAR_PROJECT_KEY_RSPON-UAT=bgsi-cicd-gaspi-rspon-uat
SONAR_PROJECT_KEY_SARDJITO-UAT=bgsi-cicd-gaspi-sardjito-uat
SONAR_PROJECT_KEY_RSNGOERAH-UAT=bgsi-cicd-gaspi-rsngoerah-uat
SONAR_PROJECT_KEY_RSJPD-UAT=bgsi-cicd-gaspi-rsjpd-uat

# Scanner Configuration
SONAR_SCANNER_IMAGE=sonarsource/sonar-scanner-cli:latest
SONAR_ANALYSIS_TIMEOUT=3600
SONAR_SCANNER_OPTS=-Xmx2048m

# Container Configuration
CONTAINER_SONAR_SCAN=bgsi_sonar_scanner
CONTAINER_SONARQUBE=bgsi_sonarqube_local
CONTAINER_IP_SONAR_SCAN=172.150.150.8
CONTAINER_IP_SONARQUBE=172.150.150.9

# Data Directories
DATA_SONAR=/opt/data/docker/sonarqube
DATA_SONAR_REPORTS=/opt/data/docker/sonarqube/reports

# Optional: Local SonarQube Server
PORT_SONARQUBE=9000
SONAR_DB_USER=postgres
SONAR_DB_PASSWORD=
SONAR_WEB_JAVAOPTS=-Xmx2048m -Xms1024m
SONAR_CE_JAVAOPTS=-Xmx2048m -Xms1024m
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
