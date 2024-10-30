import { getServerSession } from "#auth";
import type { Author, AuthorResultList } from "~/types/Author";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log(query);
  console.log(config.API_BASE_URL);
  const res: AuthorResultList = await $fetch(`${config.API_BASE_URL}/persons`, {
    params: query,
  });
  return res;
});
