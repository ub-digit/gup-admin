# gup-admin

![Alt text](./GUP-admin-setup4.png "GUP-ADMIN")
'

GUP has been removed from project and should now be run as a standalone docker-compose project. GUP and GUP-Admin share the same network where needed.

Before you run **docker-compose up -d** check

- **index-manager-db-initdb.d** should contain a file called **create.sql**
- **scopus-files/testdata** should contain scopus files in (ex 85169648502-normalised.json)
-

### index and data

cd docker
./setup_index.sh
./index.sh

Execute from gup docker-folder to get publications indexed in GUP-Admin

**docker-compose exec gup-backend bash -c 'bundle exec rake gup_migrations:add_data_for_author_import && rake db:migrate'
docker-compose exec gup-backend bash -c 'bundle exec rake gup_admin:index_all_publications LIMIT=1000 OFFSET=0'**

## FRONTEND

- USING NUXT 3
- CD frontend
- yarn install
- yarn dev
- yarn run build (to test build outside docker)

## BACKEND

- mix deps.get ---> install dependecies
- iex -S mix phx.server ----> start dev server

## FRONTEND DOCKER

- CD docker/build
- ./build.sh
- cd ..
- ./docker-compose-release.sh up
