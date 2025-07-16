#!/bin/sh
COMMAND_NAME=${1:-terraform}
TARGETPLATFORM=${2:-"linux/amd64"}
DEFAULT_VERSION=${3:-"1.8.0"}
AVAILABLE_VERSIONS=${4:-"1.8.0"}

case "${TARGETPLATFORM}" in
  "linux/amd64") ARCH=amd64 ;;
  "linux/arm64") ARCH=arm64 ;;
  "linux/arm/v7") ARCH=arm ;;
  *) echo "ERROR: 'TARGETPLATFORM' value unexpected: ${TARGETPLATFORM}"; exit 1 ;;
esac

for VERSION in ${AVAILABLE_VERSIONS}; do
  case "${COMMAND_NAME}" in
    "terraform")
      # https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
      DOWNLOAD_URL_FORMAT=$(printf 'https://releases.hashicorp.com/terraform/%s/%s_%s' "$VERSION" "$COMMAND_NAME" "$VERSION")
      COMMAND_DIR=/usr/local/bin/terraform
      FILE_EXTENSION="zip"
      ;;
    "tofu")
      # https://github.com/opentofu/opentofu/releases/download/v1.10.1/tofu_1.10.1_linux_amd64.zip
      DOWNLOAD_URL_FORMAT=$(printf 'https://github.com/opentofu/opentofu/releases/download/v%s/%s_%s' "$VERSION" "$COMMAND_NAME" "$VERSION")
      COMMAND_DIR=/usr/local/bin/tofu
      FILE_EXTENSION="zip"
      ;;
    "terragrunt")
      # https://github.com/gruntwork-io/terragrunt/releases/download/v0.82.2/terragrunt_linux_amd64
      DOWNLOAD_URL_FORMAT=$(printf 'https://github.com/gruntwork-io/terragrunt/releases/download/v%s/%s_linux_%s' "$VERSION" "$COMMAND_NAME" "$ARCH")
      COMMAND_DIR=/usr/local/bin/terragrunt
      FILE_EXTENSION="binary"
      ;;
    *) echo "ERROR: 'COMMAND_NAME' value unexpected: ${COMMAND_NAME}"; exit 1 ;;
  esac

  if [ "$COMMAND_NAME" = "terragrunt" ]; then
    # Handle terragrunt binary download
    echo "Downloading terragrunt v${VERSION}..."
    curl -LO "${DOWNLOAD_URL_FORMAT}"

    # Download checksum file
    curl -LO "https://github.com/gruntwork-io/terragrunt/releases/download/v${VERSION}/SHA256SUMS"

    # Verify checksum
    BINARY_NAME="terragrunt_linux_${ARCH}"
    if grep -q "${BINARY_NAME}" SHA256SUMS; then
      sed -n "/${BINARY_NAME}/p" SHA256SUMS | sha256sum -c
    else
      echo "Warning: Could not verify checksum for ${BINARY_NAME}"
    fi

    # Create directory and install
    mkdir -p "${COMMAND_DIR}/${VERSION}"
    chmod +x "${BINARY_NAME}"
    mv "${BINARY_NAME}" "${COMMAND_DIR}/${VERSION}/${COMMAND_NAME}"
    ln -s "${COMMAND_DIR}/${VERSION}/${COMMAND_NAME}" "${COMMAND_DIR}/${COMMAND_NAME}${VERSION}"

    # Cleanup
    rm -f SHA256SUMS
  else
    # Handle zip files (terraform, tofu)
    echo "Downloading ${COMMAND_NAME} v${VERSION}..."
    curl -LOs "${DOWNLOAD_URL_FORMAT}_linux_${ARCH}.zip"
    curl -LOs "${DOWNLOAD_URL_FORMAT}_SHA256SUMS"

    # Verify checksum
    sed -n "/${COMMAND_NAME}_${VERSION}_linux_${ARCH}.zip/p" "${COMMAND_NAME}_${VERSION}_SHA256SUMS" | sha256sum -c

    # Create directory and install
    mkdir -p "${COMMAND_DIR}/${VERSION}"
    unzip "${COMMAND_NAME}_${VERSION}_linux_${ARCH}.zip" -d "${COMMAND_DIR}/${VERSION}"
    ln -s "${COMMAND_DIR}/${VERSION}/${COMMAND_NAME}" "${COMMAND_DIR}/${COMMAND_NAME}${VERSION}"

    # Cleanup
    rm "${COMMAND_NAME}_${VERSION}_linux_${ARCH}.zip"
    rm "${COMMAND_NAME}_${VERSION}_SHA256SUMS"
  fi
done

# Create default symlink
ln -s "${COMMAND_DIR}/${DEFAULT_VERSION}/${COMMAND_NAME}" "${COMMAND_DIR}/${COMMAND_NAME}"

echo "${COMMAND_NAME} installation completed. Default version: ${DEFAULT_VERSION}"