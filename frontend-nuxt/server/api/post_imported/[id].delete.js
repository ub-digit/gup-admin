export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    const id = event.context.params.id;
    const res = $fetch(`${config.API_BASE_URL}/publications/${id}`, {method: 'DELETE'});
    return res;
})