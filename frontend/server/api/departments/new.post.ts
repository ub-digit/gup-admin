import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  query.api_key = config.ADMIN_BACKEND_API_KEY;
  const id = event?.context?.params?.id;
  const data = await readBody(event);

  console.log("data", data);

  const res = await $fetch(`${config.API_BASE_URL}/api/departments/`, {
    method: "POST",
    body: JSON.stringify({ data }),
    params: query,
  });

  return res;
});
