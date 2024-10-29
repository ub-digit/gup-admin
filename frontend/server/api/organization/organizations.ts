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
  const query = getQuery(event);
  console.log(query.query);
  const filteredData = data.filter((org) => {
    return org.name.includes(query.query);
  });
  const maxResults = 20;
  const res = {
    showing: filteredData.slice(0, maxResults).length,
    total: filteredData.length,
    data: filteredData.slice(0, maxResults),
  };
  /*
  console.log(config.API_BASE_URL);
  const res: AuthorResultList = await $fetch(`${config.API_BASE_URL}/persons`, {
    params: query,
  });*/
  return res;
});
