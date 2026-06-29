#!/bin/bash

if test "$1" = ""
then
  echo Usage: $0 git-revision-tag
  exit
fi

DOCKER_COMPOSE="docker-compose"
if command -v docker compose $> /dev/null; then
  DOCKER_COMPOSE="docker compose"
fi

git tag $1
git push origin $1
GIT_REVISION=$1 $DOCKER_COMPOSE build
./push.sh $1
