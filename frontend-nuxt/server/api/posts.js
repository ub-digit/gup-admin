export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    console.log(query);
    const res = [
        {"title": "Publikationstitel", "gup_id": "214124", "date": "2021", "pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad", "number_of_authors": "5"},
        {"title": "Publikationstitel", "gup_id": "21412423324", "date": "2021", "pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad", "number_of_authors": "5"},
        {"title": "Publikationstitel", "gup_id": "21412334", "date": "2021", "pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad", "number_of_authors": "5"},
        {"title": "Publikationstitel", "gup_id": "21413333324", "date": "2021", "pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad", "number_of_authors": "5"},
    ]
    /*  await $fetch(config.API_BASE_URL + 'databases/', {
        params: query
    }) */
    return res;
})