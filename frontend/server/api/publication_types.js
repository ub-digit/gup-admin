import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const query = getQuery(event);
  const res = await $fetch(`${config.API_BASE_URL}/publication_types`, query);
  return res.publication_types;
});
