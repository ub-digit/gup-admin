export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log(query);
  const res = await $fetch(`${config.API_BASE_URL}/publications`, {
    params: query,
  });
  return res;
});
