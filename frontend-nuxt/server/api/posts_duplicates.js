export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    let res = null;
    if (query.mode === "title") {
        res = await $fetch(`${config.API_BASE_URL}/publications/duplicates/${query.id}`,{
            params: {title: query.title, mode: query.mode}
        });
    } else if (query.mode === "id") {
        res = await $fetch(`${config.API_BASE_URL}/publications/duplicates/${query.id}/`,{
            params: {mode:'id'}
        });
    }
    return res;
})