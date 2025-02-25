import type { AuthorAffiliationArray } from "~/types/Publication";
import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }

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
