import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const res = await $fetch(config.API_BASE_URL + "alert/", {
    params: query,
  });
  return res;
});
