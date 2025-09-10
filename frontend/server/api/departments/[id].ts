import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  query.api_key = config.BACKEND_API_KEY;
  const id = event?.context?.params?.id;
  const res = await $fetch(`${config.API_BASE_URL}/api//departments/${id}`, {
    params: query,
  });

  /*const res = {
    id: 1798,
    name: "Akademin Valand",
    parent: null,
    grandparent: null,
    faculty: {
      id: 63,
      name_sv: "Konstnärliga fakulteten",
      name_en: "The Artistic Faculty",
      created_by: "system",
      updated_by: null,
      created_at: "2010-09-09T09:28:40.000Z",
      updated_at: "2023-07-03T06:55:43.632Z",
      name: "Konstnärliga fakulteten",
    },
    created_at: "2012-12-18T11:18:18.000Z",
    updated_at: "2019-11-22T14:04:38.943Z",
    name_sv: "Akademin Valand",
    name_en: "Valand Academy",
    start_year: 2012,
    end_year: 2019,
    faculty_id: 63,
    parentid: null,
    grandparentid: null,
    created_by: "xivale",
    updated_by: null,
    staffnotes: null,
    orgdbid: null,
    orgnr: "086600",
    is_internal: true,
    children: [],
  };*/
  return res;
});
