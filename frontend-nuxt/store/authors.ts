import { defineStore } from "pinia";
import { ZodError } from "zod";
import { zAuthorArray, zAuthor } from "~/types/Author";
import type { Author } from "~/types/Author"; // needs type after import to avoid error

export const useAuthorsStore = defineStore("authorsStore", () => {
  const authors: Ref<Author[]> = ref([]);
  const current_author: Ref<Author | null> = ref(null);
  const errorAuthors = ref({});
  const errorAuthor = ref({});
  const pendingAuthors = ref(false);
  interface Filter {
    name: string;
  }
  const filters: Filter = reactive({
    name: "",
  });

  async function getAuthorById(id: string) {
    try {
      const { data, error } = await useFetch(`/api/author/${id}`);
      if (data?.value?.error) {
        throw data.value;
      }
      current_author.value = zAuthor.parse(data.value as Author);
    } catch (error) {
      if (error instanceof ZodError) {
        const new_error = { code: "666", message: "ZodError", data: error };
        errorAuthor.value = new_error;
        console.log(errorAuthor.value);
        console.log("Something went wrong: getAuthorById from Zod");
      } else {
        errorAuthors.value = error.error;
        console.log(errorAuthor.value);
        console.log("Something went wrong: getAuthorById");
      }
    }
  }

  async function fetchAuthors() {
    try {
      pendingAuthors.value = true;
      const { data, error } = await useFetch("/api/author/authors");
      if (data?.value?.error) {
        throw data.value;
      }
      authors.value = zAuthorArray.parse(data.value);
    } catch (error) {
      if (error instanceof ZodError) {
        const new_error = { code: "666", message: "ZodError", data: error };
        errorAuthors.value = new_error;
        console.log(errorAuthors.value);
        console.log("Something went wrong: fetchAuthors from Zod");
      } else {
        errorAuthors.value = error.error;
        console.log(errorAuthors.value);
        console.log("Something went wrong: fetchAuthors");
      }
    } finally {
      pendingAuthors.value = false;
    }
  }

  return {
    authors,
    current_author,
    filters,
    errorAuthors,
    pendingAuthors,
    getAuthorById,
    fetchAuthors,
  };
});
