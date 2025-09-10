import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  query.api_key = config.BACKEND_API_KEY;
  const id = event?.context?.params?.id as string;
  const dataObj = await readBody(event);

  // create object formatted for backend
  const reqObj = {
    data: {
      id: dataObj.id,
      name_sv: dataObj.name_sv,
      name_en: dataObj.name_en,
      start_year: dataObj.start_year,
      end_year: dataObj.end_year,
      staffnotes: dataObj.staffnotes,
      orgdbid: dataObj.orgdbid,
      orgnr: dataObj.orgnr,
      is_internal: dataObj.is_internal,
    },
    parent_id: dataObj.parentid,
    is_faculty: dataObj.is_faculty,
  };

  const res = await $fetch(`${config.API_BASE_URL}/api/departments/${id}`, {
    method: "PUT",
    body: JSON.stringify(reqObj),
    params: query,
  });
  return res;
});
