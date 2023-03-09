export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    //console.log(query.title);
    const res = $fetch('/api/store_gup/', {});
    return res;
})