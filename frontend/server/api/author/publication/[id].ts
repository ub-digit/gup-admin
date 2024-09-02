import type {
  AuthorAffiliation,
  AuthorAffiliationArray,
} from "~/types/Publication";
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event?.context?.params?.id;
  console.log(id);
  console.log(config.API_BASE_URL);
  /*   const res: AuthorAffiliationArray = await $fetch(
    `${config.API_BASE_URL}/publication/authors`,
    {
      params: query,
    }
  ); */

  const res: AuthorAffiliationArray = {
    data: [
      {
        id: 1,
        name: "John Doe 1",
        affiliation_str: "University of Oslo",
      },
      {
        id: 2,
        name: "John Doe 2",
        affiliation_str: "University of Oslo",
      },
      {
        id: 3,
        name: "John Doe 3",
        affiliation_str: "University of Oslo",
      },
    ],
  };
  return res;
});
