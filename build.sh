#!/bin/bash
set -e

APP_NAME="aws-elastic-beanstalk-express-js-sample"
DOCKER_IMAGE="riazul99/${APP_NAME}"
BUILD_NUMBER=$(date +%Y%m%d%H%M)   # use timestamp if BUILD_NUMBER not available

echo "==> Building Docker image: $DOCKER_IMAGE:$BUILD_NUMBER"

# Build image
docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .

echo "==> Logging in to DockerHub..."
docker login -u "riazul99"

echo "==> Pushing images..."
docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
docker push ${DOCKER_IMAGE}:latest

echo "==> Done!"
