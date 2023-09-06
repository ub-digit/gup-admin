# gup-admin

![Alt text](./GUP-admin-setup4.png "a title")

## index GUP Posts

docker-compose exec gup-backend bash -c 'bundle exec rake gup_admin:index_all LIMIT=1000 OFFSET=0'
cd /usr/src/app

## index WoS Posts

docker-compose exec gup-imports bash -c 'python3 /data/scripts/put-scopus-docs.py -d /data/files/scopus-normalised/testdata -u $GUP_ADMIN_BASE_URL -a $GUP_ADMIN_API_KEY'

## TODO

## FRONTEND

- USING NUXT 3
- CD nuxt-frontend
- yarn install
- yarn run dev
- yarn run build (to test build outside docker)

## BACKEND

- iex -S mix phx.server

### FRONTEND DOCKER

- CD docker/build
- ./build.sh frontend-nuxt
- cd ..
- ./docker-compose-release.sh up

### DOCKER LAB

- Läser in temp-filer (json) för att få data till elasticsearch under utveckling. För att få indexet uppdatterat kör skript ./index.sh efter att elasticsearch är igång

### DISKUTERA

- 404 sidor (utseende)
- Nivå på felhantering (vet inte exakt vad jag menar)
- Namn på olika parametrar i filter på queryparam?
- Verikal skroll på filtrerade poster eller inte?
