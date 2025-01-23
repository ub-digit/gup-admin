import type { Author } from "~/types/Author";
import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event?.context?.params?.id;
  const data = await readBody(event);
  const res = {
    data: data,
    errors: ["X_ACCOUNT_WRONG_FORMAT", "INVALID_BIRTHYEAR"],
  };
  console.log(res);
  return res;

  /*
  console.log("from put to author");
  console.log("id", id);
  console.log("data", data);
  const res = await $fetch(`${config.API_BASE_URL}/person/${id}`, {
    method: "POST",
    body: JSON.stringify(data),
  });
  return res;*/
});
