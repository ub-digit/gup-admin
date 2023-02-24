export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    //const res = await $fetch(config.API_BASE_URL + 'databases/popular/', {params: query})
    const res = ['journal_article', 'review_article', 'magazine_article', 'editorial_letter']
    return res;
})