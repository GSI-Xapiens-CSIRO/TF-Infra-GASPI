# SonarQube Integration for GXC Atlantis Deploy

This document describes the SonarQube integration added to the GXC Atlantis deployment workflow.

## Overview

The SonarQube integration provides automated code quality analysis as part of the Atlantis deployment pipeline. It runs before the application tests and Terraform operations to ensure code quality standards are met.

## Files Added

1. **`sonar-scan`** - SonarQube scanner script
2. **`sonarqube.env.example`** - Configuration template
3. **Updated `atlantis-deploy`** - Main deployment script with SonarQube integration

## Setup Instructions

### 1. Configure SonarQube Server

Ensure you have a SonarQube server running and accessible. You'll need:
- SonarQube server URL
- Authentication token with project creation permissions

### 2. Create Configuration File

Copy the example configuration:
```bash
cp sonarqube.env.example sonarqube.env
```

Edit `sonarqube.env` with your actual values:
```bash
# Required
SONAR_HOST_URL=http://your-sonarqube-server:9000
SONAR_TOKEN=your_actual_sonarqube_token

# Optional - enable/disable SonarQube scanning
SCRIPT_RUN_SONAR=true
```

### 3. Source Configuration (Optional)

You can source the configuration file in your environment:
```bash
source sonarqube.env
```

Or set the environment variables directly in your Atlantis configuration.

## Usage

### Automatic Integration

The SonarQube scan runs automatically as part of the `atlantis-deploy` workflow when `SCRIPT_RUN_SONAR=true` (default).

```bash
./atlantis-deploy hub01 plan   # Includes SonarQube scan
./atlantis-deploy uat02 apply  # Includes SonarQube scan
```

### Manual SonarQube Scan

You can also run the SonarQube scan independently:

```bash
# Scan with environment-specific configuration
./sonar-scan hub01

# Scan with default configuration
./sonar-scan

# Dry run to see configuration
./sonar-scan --dry-run

# Custom configuration
./sonar-scan --project-key my-project --sources ./src
```

### Disable SonarQube Scanning

To skip SonarQube scanning in the deployment workflow:

```bash
SCRIPT_RUN_SONAR=false ./atlantis-deploy hub01 plan
```

## Environment Variables

### Required
- `SONAR_HOST_URL` - SonarQube server URL
- `SONAR_TOKEN` - SonarQube authentication token

### Optional
- `SCRIPT_RUN_SONAR` - Enable/disable SonarQube scanning (default: true)
- `SONAR_PROJECT_KEY` - Override project key (default: gxc-gaspi-${ENVIRONMENT})
- `SONAR_PROJECT_NAME` - Override project name (default: GXC-GASPI-${ENVIRONMENT^^})
- `SONAR_PROJECT_VERSION` - Project version (default: 1.0.0)
- `SONAR_SOURCES` - Source directories to scan (default: .)
- `SONAR_EXCLUSIONS` - Files/patterns to exclude
- `SONAR_TIMEOUT` - Scan timeout in seconds (default: 600)
- `SONAR_FAIL_ON_ERROR` - Fail deployment on scan error (default: true)

## Integration Workflow

The SonarQube integration is positioned in the deployment workflow as follows:

1. **Setup Phase**
   - Validate prerequisites
   - Setup environment variables
   - Configure Git and AWS credentials

2. **Repository Initialization**
   - Initialize submodules
   - Setup Terraform configuration

3. **🆕 SonarQube Analysis** (NEW)
   - Run code quality analysis
   - Generate quality reports
   - Check quality gates

4. **Application Tests**
   - Run application test suites
   - Validate functionality

5. **Terraform Operations**
   - Plan or Apply infrastructure changes

## Quality Gate Handling

- **Pass**: Deployment continues to next phase
- **Fail (SONAR_FAIL_ON_ERROR=true)**: Deployment stops, returns error
- **Fail (SONAR_FAIL_ON_ERROR=false)**: Warning logged, deployment continues

## Project Configuration

The SonarQube scan automatically creates environment-specific projects:

- Hub environments: `gxc-gaspi-hub01`, `gxc-gaspi-hub02`, etc.
- UAT environments: `gxc-gaspi-uat01`, `gxc-gaspi-uat02`, etc.
- Default: `gxc-gaspi-default`

## Exclusions

Default exclusions include:
- `**/*.tfvars` - Terraform variable files
- `**/*.tf.example` - Example Terraform files
- `**/node_modules/**` - Node.js dependencies
- `**/.terraform/**` - Terraform cache
- `**/.git/**` - Git metadata
- `**/coverage/**` - Coverage reports
- `**/build/**` - Build artifacts
- `**/dist/**` - Distribution files

## Troubleshooting

### Common Issues

1. **Docker not available**
   - Ensure Docker is installed and running
   - Check Docker daemon status

2. **SonarQube server unreachable**
   - Verify `SONAR_HOST_URL` is correct
   - Check network connectivity
   - Verify server is running

3. **Authentication failed**
   - Verify `SONAR_TOKEN` is correct
   - Check token permissions in SonarQube

4. **Scan timeout**
   - Increase `SONAR_TIMEOUT` value
   - Check project size and complexity

### Debug Mode

Run with debug information:
```bash
./sonar-scan --dry-run  # Show configuration without running
```

### Logs

SonarQube scan logs are integrated with the main deployment logs and include:
- Configuration display
- Scan progress
- Quality gate results
- Error details (if any)

## Security Considerations

- Store `SONAR_TOKEN` securely (use secrets management)
- Avoid committing `sonarqube.env` to version control
- Use dedicated service accounts for SonarQube authentication
- Regularly rotate authentication tokens

## Support

For issues related to:
- **SonarQube integration**: Contact GXC DevOps Team (support-gxc@xapiens.id)
- **SonarQube server**: Contact your SonarQube administrator
- **Atlantis deployment**: Refer to main Atlantis documentation