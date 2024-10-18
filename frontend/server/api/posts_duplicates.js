import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  let res = null;
  if (query.mode === "title") {
    res = await $fetch(
      `${config.API_BASE_URL}/publications/duplicates/${query.id}`,
      {
        params: { title: query.title, mode: query.mode },
      }
    );
  } else if (query.mode === "id") {
    res = await $fetch(
      `${config.API_BASE_URL}/publications/duplicates/${query.id}/`,
      {
        params: { mode: "id" },
      }
    );
  }
  return res;
});
