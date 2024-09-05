import type {
  AuthorAffiliation,
  AuthorAffiliationArray,
} from "~/types/Publication";
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event?.context?.params?.id;
  const res: AuthorAffiliationArray = await $fetch(
    `${config.API_BASE_URL}/publications/${id}/authors`,
    {
      params: query,
    }
  );
  return res;
});
