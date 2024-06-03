#!/bin/bash
DOCKER_COMPOSE="docker-compose"
if command -v docker compose $> /dev/null; then
  DOCKER_COMPOSE="docker compose"
fi
$DOCKER_COMPOSE -f docker-compose.yml -f docker-compose.release.yml "$@"
