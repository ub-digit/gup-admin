import type {
  Organization,
  OrganizationResultList,
} from "~/types/Organizations";

import { data } from "./data";
import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const res = {
    data: data,
  };
  /*
  console.log(config.API_BASE_URL);
  const res: AuthorResultList = await $fetch(`${config.API_BASE_URL}/persons`, {
    params: query,
  });*/
  return res;
});
