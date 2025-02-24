import { getServerSession } from "#auth";

import type { Identifier, IdentifierArray } from "~/types/Identifier";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  query.api_key = config.ADMIN_BACKEND_API_KEY;
  console.log(config.API_BASE_URL);

  /*const res: IdentifierArray = [
    {
      code: "X_ACCOUNT",
      value: "x-account",
    },
    {
      code: "ORCID",
      value: "Orcid",
    },
    {
      code: "CID",
      value: "Cid",
    },
    {
      code: "SCOPUS_AUTHOR_ID",
      value: "Scopus author id",
    },
    {
      code: "WOS_RESEARCHER_ID",
      value: "Wos researcher id",
    },
    {
      code: "WOS_DAISNG_ID",
      value: "Wos daisng id",
    },
    {
      code: "POP_ID",
      value: "Pop id",
    },
  ];*/
  const res = await $fetch(`${config.API_BASE_URL}/api/person_id_codes`, {
    params: query,
  });
  // wrap each object in the array with an object with a data key
  const res_with_obj = res?.id_codes?.map((item: string) => ({ code: item }));
  return res_with_obj;
});
