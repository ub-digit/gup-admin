import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }

  const config = useRuntimeConfig();
  const query = getQuery(event);

  console.log(config.API_BASE_URL);
  const res = await $fetch(`${config.API_BASE_URL}/publications`, {
    params: query,
  });
  return res;
});
