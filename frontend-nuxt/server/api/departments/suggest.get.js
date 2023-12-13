export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log("query", query);
  /*const res = [
    {
      id: 1,
      name: "it-fakulteten",
    },
    {
      id: 2,
      name: "it-fakulteten 1",
    },
    {
      id: 3,
      name: "it-fakulteten 2",
    },
    {
      id: 4,
      name: "it-fakulteten 3",
    },
  ]; */
  const res = await $fetch(
    `${config.API_BASE_URL}/departments/?term=${query.term}&year=${query.year}`
  );
  return res;
});
