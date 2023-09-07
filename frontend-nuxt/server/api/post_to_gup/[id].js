export default defineEventHandler(async (event) => {
  /*     throw createError({
        statusCode: 411,
        statusMessage: 'Could not create post',
      }) */
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event.context.params.id;
  const res = await $fetch(
    `${config.API_BASE_URL}/publications/post_to_gup/${id}/${query.user}`,
    { method: "POST" },
  );
  return res;
});
