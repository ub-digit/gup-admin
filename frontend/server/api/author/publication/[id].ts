import type { Author, AuthorResultList } from "~/types/Author";
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const id = event?.context?.params?.id;
  console.log(id);
  console.log(config.API_BASE_URL);
  const res: AuthorResultList = await $fetch(`${config.API_BASE_URL}/persons`, {
    params: query,
  });

  /*const res: AuthorResultList = {
    showing: 1,
    total: 4,
    data: [
      {
        id: "2",
        year_of_birth: 1985,
        identifiers: [],
        email: "",
        names: [
          {
            first_name: "Jane",
            last_name: "Doe",
            gup_person_id: "123",
            start_date: "2021-01-01",
            end_date: "2021-01-01",
            primary: true,
          },
          {
            first_name: "John",
            last_name: "Doe",
            gup_person_id: "123",
            start_date: "2021-01-01",
            end_date: "2021-01-01",
            primary: false,
          },
          {
            first_name: "Jill",
            last_name: "Doe",
            gup_person_id: "123",
            start_date: "2021-01-01",
            end_date: "2021-01-01",
            primary: false,
          },
        ],
        departments: [
          {
            id: "1",
            name: "Department of Computer Science",
            type: "type",
            start_date: "2021-01-01",
            end_date: "2021-01-01",
            current: false,
          },
          {
            id: "2",
            name: "Department of Physics",
            type: "type",
            start_date: "2021-01-01",
            end_date: null,
            current: true,
          },
        ],
      },
    ],
  };*/
  return res;
});
