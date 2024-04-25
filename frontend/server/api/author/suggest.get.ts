import type { AuthorResultList } from "~/types/Author";
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);

  console.log("query", query);

  const res: AuthorResultList = await $fetch(`${config.API_BASE_URL}/persons`, {
    params: query,
  });
  return res;
});
