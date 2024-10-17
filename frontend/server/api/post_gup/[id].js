import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event.context.params.id;
  const res = await $fetch(`${config.API_BASE_URL}/publications/${id}`); //createError({ statusCode: 404, statusMessage: 'Post Not Found' })//$fetch('/api/store_gup/', {query: {id: id}});
  return res;
});
