export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    console.log(query)
    const id = event.context.params.id;
    const res = await $fetch(`${config.API_BASE_URL}/publications/post_to_gup/${id}/undefined`, {method: 'POST'});
    return res;
})