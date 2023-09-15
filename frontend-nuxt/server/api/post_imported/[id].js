export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event.context.params.id;
  const res = await $fetch(`${config.API_BASE_URL}/publications/${id}`);
  return res;
});
