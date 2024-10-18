import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log(query);
  const res = await $fetch(
    `${config.API_BASE_URL}/publications/merge/${query.id}/${query.gupid}/${query.user}`,
    { method: "POST" }
  );
  return res;
});
