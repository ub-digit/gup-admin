export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    const id = event.context.params.id;
    const res = $fetch('/api/store_imported/', {
       query: {id: id} 
    });
    return res;
})