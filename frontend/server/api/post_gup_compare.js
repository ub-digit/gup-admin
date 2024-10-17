import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event.context.params.id;
  try {
    const res = await $fetch(
      `${config.API_BASE_URL}publications/compare/imported_id/${query.imported_id}/gup_id/${query.gup_id}`
    );
    return res;
  } catch (error) {
    return error.data;
  }
});
