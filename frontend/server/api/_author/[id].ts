import type { Author } from "~/types/Author";
import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  query.api_key = config.ADMIN_BACKEND_API_KEY;
  interface AuthorObject {
    data: Author[];
  }

  console.log(config.API_BASE_URL);
  const id = event?.context?.params?.id;
  const res: AuthorObject = await $fetch(
    `${config.API_BASE_URL}/api/persons/${id}`,
    {
      params: query,
    }
  );
  /* 
  const res: Author = {
    id: 2,
    year_of_birth: 1985,
    identifiers: [
      {
        code: "X_ACCOUNT",
        value: "xlpero",
      },
      {
        code: "SCOPUS_AUTHOR_ID",
        value: "X12345678",
      },
      {
        code: "ORCID",
        value: "X12345678",
      },
      {
        code: "WOS_RESEARCHER_ID",
        value: "000000012156142X",
      },
      {
        code: "CID",
        value: "X12345678",
      },
      {
        code: "POP_ID",
        value: "X1234567S",
      },
    ],
    email: "",
    names: [
      {
        first_name: "Jane",
        last_name: "Doe",
        gup_person_id: 16,
        start_date: "2021-01-01",
        end_date: "2021-01-01",
        primary: true,
      },
      {
        first_name: "John",
        last_name: "Doe",
        gup_person_id: 17,
        start_date: "2021-01-01",
        end_date: "2021-01-01",
        primary: false,
      },
      {
        first_name: "Jill",
        last_name: "Doe",
        gup_person_id: 17,
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
  }; */
  return res;
});
