#!/usr/bin/env sh
# -----------------------------------------------------------------------------
#  Container Image Builder for ECR (Elastic Container Registry) or DockerHub
# -----------------------------------------------------------------------------
#  Author     : Dwi Fahni Denni
#  License    : Apache v2
# -----------------------------------------------------------------------------
set -euo pipefail

export AWS_ACCOUNT_ID=$1
export AWS_REGION="ap-southeast-3"
export CI_PROJECT_REGISTRY="docker.io"
export CI_PROJECT_REGISTRY_ECR="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/bgsi/devops"
export CI_PROJECT_PATH="bgsi-devops"
export CI_PROJECT_NAME="atlantis-bgsi"
export DOCKER_DEFAULT_PLATFORM=linux/amd64

export IMAGE="$CI_PROJECT_REGISTRY/$CI_PROJECT_PATH/$CI_PROJECT_NAME"
export IMAGE_ECR="$CI_PROJECT_REGISTRY_ECR/$CI_PROJECT_NAME"

PATH_FOLDER=`pwd`

TAG_VERSION="2.4.0"
TAG_ID=`echo $(date '+%Y%m%d')`

LINE_PRINT="======================================================="

login_ecr() {
  echo "============="
  echo "  Login ECR  "
  echo "============="
  PASSWORD=`aws ecr get-login-password --region $AWS_REGION`
  echo $PASSWORD | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
  echo '- DONE -'
  echo ''
}

docker_atlantis() {
  echo $LINE_PRINT
  echo " DOCKER BUILD ATLANTIS TAG $TAG_VERSION-$TAG_ID "
  echo $LINE_PRINT
  echo "docker build --no-cache -f Dockerfile -t $IMAGE:$TAG_VERSION ."
  docker build --no-cache -f Dockerfile -t $IMAGE:$TAG_VERSION .
  echo ' - DONE -'
  echo ''
}

tag_atlantis() {
   echo $LINE_PRINT
   echo " DOCKER TAG ATLANTIS $TAG_VERSION-$TAG_ID "
   echo $LINE_PRINT
   echo "docker tag $IMAGE:$TAG_VERSION $IMAGE:$TAG_VERSION-$TAG_ID
docker tag $IMAGE:$TAG_VERSION $IMAGE:latest
docker tag $IMAGE:$TAG_VERSION $IMAGE:$TAG_ID"

docker tag $IMAGE:$TAG_VERSION $IMAGE:$TAG_VERSION-$TAG_ID
docker tag $IMAGE:$TAG_VERSION $IMAGE:latest
docker tag $IMAGE:$TAG_VERSION $IMAGE:$TAG_ID
   echo ' - DONE -'
   echo ''
}

push_atlantis() {
  echo $LINE_PRINT
  echo " DOCKER PUSH ATLANTIS $TAG_VERSION-$TAG_ID "
  echo $LINE_PRINT
  PUSH_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep $CI_PROJECT_NAME)
  for IMG in $PUSH_IMAGES; do
    echo "Docker Push => $IMG"
    echo ">> docker push $IMG"
    docker push $IMG
    echo '- DONE -'
    echo ''
  done
}

push_atlantis_latest() {
  echo $LINE_PRINT
  echo " DOCKER PUSH ATLANTIS $TAG_VERSION-$TAG_ID "
  echo $LINE_PRINT
  PUSH_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep latest)
  for IMG in $PUSH_IMAGES; do
    echo "Docker Push => $IMG"
    echo ">> docker push $IMG"
    docker push $IMG
    echo '- DONE -'
    echo ''
  done
}

push_atlantis_ecr() {
  echo $LINE_PRINT
  echo " DOCKER PUSH xignals $TAG_VERSION-$TAG_ID "
  echo $LINE_PRINT
  PUSH_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep $AWS_ACCOUNT_ID)
  for IMG in $PUSH_IMAGES; do
    echo "Docker Push => $IMG"
    echo ">> docker push $IMG"
    docker push $IMG
    echo '- DONE -'
    echo ''
  done
}

docker_build() {
  docker_atlantis
}

docker_tag() {
  tag_atlantis
}

docker_push(){
  push_atlantis
  push_atlantis_latest
}

ecr_push() {
  ## AWS_ACCOUNT_ID Tags ##
  login_ecr
  push_atlantis_ecr
}

docker_clean() {
    echo "Cleanup Unknown Tags"
    echo "docker images -a | grep none | awk '{ print \$3; }' | xargs docker rmi"
    docker images -a | grep none | awk '{ print $3; }' | xargs docker rmi
    echo '- DONE -'
    echo ''
}


main() {
  docker_build
  docker_tag
  docker_clean
  docker_push
  # ecr_push
  echo '-- ALL DONE --'
}

### START HERE ###
main
