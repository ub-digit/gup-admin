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
      value: "x-account_value",
    },
    {
      code: "foo",
      value: "foo_value",
    },
    {
      code: "bar",
      value: "bar_value",
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
