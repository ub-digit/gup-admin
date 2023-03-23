# gup-admin 

## TODO


## FRONTEND 
* USING NUXT 3
* CD nuxt-frontend
* yarn install
* yarn run dev
* yarn run build (to test build outside docker)


### FRONTEND DOCKER 
* CD docker/build
* ./build.sh frontend-nuxt
* cd ..  
* ./docker-compose-release.sh up


### DOCKER LAB
* Läser in temp-filer (json) för att få data till elasticsearch under utveckling. För att få indexet uppdatterat kör skript ./index.sh efter att elasticsearch är igång
