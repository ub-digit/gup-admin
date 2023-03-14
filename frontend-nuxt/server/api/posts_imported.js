export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    console.log(query)
    const res = $fetch('/api/store_imported/', {});
    return res;
})