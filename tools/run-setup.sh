#!/bin/bash
mkdir -p /opt/data/docker/jupyter/{notebooks,aws}
cp .env.example .env
echo "Setup complete. Edit .env and add AWS credentials to /opt/data/docker/jupyter/aws/"
echo "Run: docker-compose -f docker-jupyternotebook.yml up -d"
