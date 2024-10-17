import type { Department } from "~/types/Author";
import { getServerSession } from "#auth";
export default defineEventHandler(async (event) => {
  const session = await getServerSession(event);
  if (!session) {
    return { status: 401, body: { message: "Unauthorized" } };
  }
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log("query", query);
  const res: Department[] = [
    {
      id: 1,
      name: "it-fakulteten",
      type: "department",
      start_date: "2020-01-01",
      end_date: null,
    },
    {
      id: 2,
      name: "it-fakulteten 1",
      type: "department",
      start_date: "2020-01-01",
      end_date: null,
    },
    {
      id: 3,
      name: "it-fakulteten 2",
      type: "department",
      start_date: "2020-01-01",
      end_date: null,
    },
    {
      id: 4,
      name: "it-fakulteten 3",
      type: "department",
      start_date: "2020-01-01",
      end_date: null,
    },
  ];

  /*   const res = await $fetch(
    `${config.API_BASE_URL}/departments/?term=${query.term}&year=${query.year}`
  ); */
  return res;
});
