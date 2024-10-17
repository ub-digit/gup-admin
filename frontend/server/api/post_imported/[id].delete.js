import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  /*     throw createError({
        statusCode: 400,
        statusMessage: 'ID should be an integer',
      }) */
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event.context.params.id;
  const res = $fetch(`${config.API_BASE_URL}/publications/${id}`, {
    method: "DELETE",
  });
  return res;
});
