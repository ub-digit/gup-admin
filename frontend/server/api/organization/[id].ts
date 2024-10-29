import type { Organization } from "~/types/Organizations";
import { getServerSession } from "#auth";
import { data } from "./data";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);

  interface OrganizationObject {
    data: Organization[];
  }

  const id = event?.context?.params?.id;
  /*   const res: AuthorObject = await $fetch(
    `${config.API_BASE_URL}persons/${id}`,
    {
      params: query,
    }
  ); */

  // find the organization with the id
  const org = data.find((org) => org.id === parseInt(id as string));
  const res: OrganizationObject = { data: org };
  return res.data;
});
