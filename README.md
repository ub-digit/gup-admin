# gup-admin

![Alt text](./GUP-admin-setup4.png "GUP-ADMIN")

## index all stuff

cd docker
docker-compose exec gup-backend bash -c 'bundle exec rake gup_migrations:add_data_for_author_import && rake db:migrate'
./setup_index.sh
./index.sh

## index GUP Posts

docker-compose exec gup-backend bash -c 'bundle exec rake gup_admin:index_all_publications LIMIT=1000 OFFSET=0'

## index WoS Posts

docker-compose exec gup-imports bash -c 'python3 /data/scripts/put-scopus-docs.py -d /data/files/scopus-normalised/testdata -u http://index-manager-backend:4000 -a $GUP_INDEX_MANAGER_API_KEY'

##

## index departments

docker-compose exec index-manager-backend mix run -e "GupIndexManager.Resource.Departments.initialize |> IO.inspect()"

## TODO

## FRONTEND

- USING NUXT 3
- CD nuxt-frontend
- yarn install
- yarn dev
- yarn run build (to test build outside docker)

## BACKEND

- mix deps.get ---> install dependecies
- iex -S mix phx.server ----> start dev server

### FRONTEND DOCKER

- CD docker/build
- ./build.sh
- cd ..
- ./docker-compose-release.sh up

### DOCKER LAB

### DISKUTERA

- 404 sidor (utseende)
- Nivå på felhantering (vet inte exakt vad jag menar)
- Namn på olika parametrar i filter på queryparam?
- Verikal skroll på filtrerade poster eller inte? höjd?
