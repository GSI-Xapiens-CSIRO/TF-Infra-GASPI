# Jupyter Notebook Tools for GASPI

Development tools for GASPI infrastructure management.

## Jupyter Notebook with AWS Integration

Interactive Python environment for AWS resource analysis and Terraform operations.

### Setup

```bash
# Run setup script
./run-setup.sh
cp .env.example .env

# Configure AWS credentials
cat > /opt/data/docker/jupyter/aws/credentials << EOF
[default]
aws_access_key_id = <YOUR_ACCESS_KEY>
aws_secret_access_key = <YOUR_SECRET_KEY>
EOF

cat > /opt/data/docker/jupyter/aws/config << EOF
[default]
region = ap-southeast-3
output = json
EOF

# Edit environment variables (optional)
vi .env
```

### Usage

```bash
# Start services
docker-compose -f docker-jupyternotebook.yml up -d

# Access Jupyter Notebook
open http://localhost:8888

# Access Portainer
open http://localhost:5212

# Stop services
docker-compose -f docker-jupyternotebook.yml down
```

### Features

- **Jupyter Notebook**: Python environment with boto3 and AWS CLI pre-installed
- **Portainer**: Docker container management UI
- **AWS Integration**: Mounted AWS credentials for seamless AWS operations

### Default Ports

- Jupyter: `8888`
- Portainer: `5212`

### Volumes

- Notebooks: `/opt/data/docker/jupyter/notebooks`
- AWS Config: `/opt/data/docker/jupyter/aws`
