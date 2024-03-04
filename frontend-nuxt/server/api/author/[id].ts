import type { Author } from "~/types/Author";
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);

  console.log(config.API_BASE_URL);
  /*   const res = await $fetch(`${config.API_BASE_URL}/publications`, {
    params: query,
  }); */

  const res = {
    id: 2,
    year_of_birth: 1985,
    identifiers: [
      {
        code: "X-ACCOUNT",
        value: "xlpero",
      },
      {
        code: "SCOPUS-AUTHOR-ID",
        value: "X12345678",
      },
      {
        code: "ORCID",
        value: "X12345678",
      },
      {
        code: "WOS-RESEARCHER-ID",
        value: "000000012156142X",
      },
      {
        code: "CID",
        value: "X12345678",
      },
      {
        code: "POP-ID",
        value: "X1234567S",
      },
    ],
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
        id: 1,
        name: "Department of Computer Science",
        type: "type",
        start_date: "2021-01-01",
        end_date: "2021-01-01",
        current: false,
      },
      {
        id: 2,
        name: "Department of Physics",
        type: "type",
        start_date: "2021-01-01",
        end_date: null,
        current: true,
      },
    ],
  };
  return res;
});
