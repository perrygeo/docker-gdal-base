#!/bin/bash
# Lots of assumptions about ENV VARS set in travis.yml
set -e

echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
docker tag $TAG $REPO:latest
docker push $REPO
