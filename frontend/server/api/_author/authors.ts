import { getServerSession } from "#auth";
import type { Author, AuthorResultList } from "~/types/Author";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized is here" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log(query);
  query.api_key = config.ADMIN_BACKEND_API_KEY;
  console.log(config.API_BASE_URL);
  console.log(config.ADMIN_BACKEND_API_KEY);
  const res: AuthorResultList = await $fetch(`${config.API_BASE_URL}/persons`, {
    params: query,
  });
  return res;
});
