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
  const body = await readBody(event);

  console.log(body);
  return { status: 200, body: { message: "ok" } };
  /*const res = useFetch(`${config.API_BASE_URL}/publications/${id}`, {
    method: "PUT",
  });*/
  //return res;
});
