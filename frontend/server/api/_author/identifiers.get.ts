import { getServerSession } from "#auth";

import type { Identifier, IdentifierArray } from "~/types/Identifier";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log(config.API_BASE_URL);

  const res: IdentifierArray = [
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
  ];
  /*const res: IdentifierArray = await $fetch(
    `${config.API_BASE_URL}/identifers`,
    {
      params: query,
    }
  );*/
  return res;
});
