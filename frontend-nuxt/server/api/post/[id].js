export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    const id = event.context.params.id;
    const res = {"title": "Publikationstitel", "gup_id": "214124", "date": "2021", "pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad", "number_of_authors": "5"};
   /* const res = await $fetch(config.API_BASE_URL + `databases/${id}`, {
        params: query
    })*/
    return res;
})