#!/bin/bash
source .env

# Overwrite GIT_REVISION with first argument if passed
if [ -n "$1" ]; then
  GIT_REVISION=$1
fi

docker push docker.ub.gu.se/db-list-elasticsearch:${GIT_REVISION} && \
docker push docker.ub.gu.se/db-list-backend-admin:${GIT_REVISION} && \
docker push docker.ub.gu.se/db-list-backend:${GIT_REVISION} && \
docker push docker.ub.gu.se/db-list-frontend-admin:${GIT_REVISION}
docker push docker.ub.gu.se/db-list-frontend-nuxt-3:${GIT_REVISION}