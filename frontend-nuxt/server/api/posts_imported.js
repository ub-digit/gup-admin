export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    const res = $fetch('/api/store_imported/', {});
    return res;
})