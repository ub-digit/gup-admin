#!/bin/bash
source .env

# Overwrite GIT_REVISION with first argument if passed
if [ -n "$1" ]; then
  GIT_REVISION=$1
fi

docker push docker.ub.gu.se/gup-admin-elasticsearch:${GIT_REVISION} && \
docker push docker.ub.gu.se/gup-admin-backend-admin:${GIT_REVISION} && \
docker push docker.ub.gu.se/gup-admin-backend:${GIT_REVISION} && \
docker push docker.ub.gu.se/gup-admin-frontend-admin:${GIT_REVISION}
docker push docker.ub.gu.se/gup-admin-frontend-nuxt-3:${GIT_REVISION}