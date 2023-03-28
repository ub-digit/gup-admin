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



### DISKUTERA
* fullwidth container (som fjärrkontrollen)
    * eventuell maxbredd?
* Helt ignorera mobilläge?
* 404 sidor
* namn på olika saker i filter på queryparam? 
* Verikal skroll på filtrerade poster eller inte?
* id: GUP-345435 istället för GUP: 32234532
    * ligger även under titel nu (ej som skiss; orsakt platsbrist) 
* "statusrad" på postvisning är oklar för mig (vad betyder "AV" i ett sammanhang där man klickat på en SCOPUS eller WoS post)
