import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  query.api_key = config.ADMIN_BACKEND_API_KEY;
  const id = event?.context?.params?.id as string;
  const data = await readBody(event);

  const res = await $fetch(`${config.API_BASE_URL}/api/departments/${id}`, {
    method: "PUT",
    body: JSON.stringify({ data }),
    params: query,
  });
  return res;
});
