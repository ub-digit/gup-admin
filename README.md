# gup-admin 

## TODO


## FRONTEND 
* USING NUXT 3
* CD nuxt-frontend
* yarn install
* yarn run dev
* yarn run build (to test build outside docker)

## BACKEND
* iex -S mix phx.server 

### FRONTEND DOCKER 
* CD docker/build
* ./build.sh frontend-nuxt
* cd ..  
* ./docker-compose-release.sh up


### DOCKER LAB
* Läser in temp-filer (json) för att få data till elasticsearch under utveckling. För att få indexet uppdatterat kör skript ./index.sh efter att elasticsearch är igång



### DISKUTERA
* Fullwidth container (som fjärrkontrollen)
    * eventuell maxbredd?
* Helt ignorera mobilläge?
* 404 sidor (utseende)
* Nivå på felhantering (vet inte exakt vad jag menar)
* Namn på olika parametrar i filter på queryparam? 
* Verikal skroll på filtrerade poster eller inte?
* id: GUP-345435 istället för GUP: 32234532
    * ligger även under titel nu (ej som skiss; orsak platsbrist) 
* "statusrad" på postvisning är oklar för mig (vad betyder "AV" i ett sammanhang där man klickat på en SCOPUS eller WoS post)
* Hur hantera radhöjder när posterna visas sida vid sida och har olika höjd? 
    * javascriptlösning krympa font-size till vad som får plats i en fast höjd?
    * Samma tabell för båda och låta den växa till största värdet (jobbigt med olika NuxtPage (dvs outlets)
    * Ignorera så länge

