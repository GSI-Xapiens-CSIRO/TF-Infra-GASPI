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
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

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

# Copy atlantis-deploy script
COPY docker-entrypoint.sh /home/atlantis
COPY scripts/atlantis-deploy /usr/local/bin/atlantis-deploy
COPY scripts/install-atlantis-deploy /usr/local/bin/install-atlantis-deploy

# Set the exposed port
EXPOSE ${ATLANTIS_PORT:-4141}

# Health check
HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f http://localhost:${ATLANTIS_PORT:-4141}/healthz || exit 1

WORKDIR /home/atlantis

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["server"]