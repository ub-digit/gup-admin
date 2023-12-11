export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log("query", query);
  const res = [
    {
      id: 1,
      x_account: "xljoha",
      full_name: "johan larsson",
      departments: [
        { id: 1, name: "bar foo" },
        { id: 2, name: "foo bar" },
      ],
    },
    {
      id: 2,
      x_account: "xavgo",
      full_name: "johan avg",
      departments: [{ id: 1, name: "bar foo" }],
    },
    {
      id: 3,
      x_account: "xlpero",
      full_name: "Pär Larsson",
      departments: [{ id: 1, name: "bar foo" }],
    },
    {
      id: 4,
      x_account: "xlpero",
      full_name: "Pär Larsson",
      departments: [{ id: 1, name: "bar foo" }],
    },
    {
      id: 5,
      x_account: "xlpero",
      full_name: "Pär Larsson",
      departments: [{ id: 1, name: "bar foo" }],
    },
    {
      id: 6,
      x_account: "xlpero",
      full_name: "Pär Larsson",
      departments: [{ id: 1, name: "bar foo" }],
    },
  ]; //await $fetch(`${config.API_BASE_URL}/publication_types`, query);
  return res;
});
