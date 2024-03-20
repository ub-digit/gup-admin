import { defineStore } from "pinia";
import { ZodError, number } from "zod";
import { zAuthorArray, zAuthor, zAuthorResultList } from "~/types/Author";
import type { Author } from "~/types/Author"; // needs type after import to avoid error
import _ from "lodash";
import { useDebounceFn } from "@vueuse/core";

export const useAuthorsStore = defineStore("authorsStore", () => {
  const { getLocale } = useI18n();
  const route = useRoute();
  const router = useRouter();

  const authorsByPublication: Ref<Author[]> = ref([]);
  const authors: Ref<Author[]> = ref([]);
  interface Meta {
    total: number;
    showing: number;
  }
  const authorsMeta: Ref<Meta> = ref({ total: 0, showing: 0 });
  const author: Ref<Author | null> = ref(null);
  const errorAuthors = ref({});
  const errorAuthor = ref({});
  const pendingAuthors = ref(false);

  interface Filter {
    query: string;
  }
  const filters: Filter = reactive({
    query: route.query.query ? (route.query.query as string) : "",
  });

  function $reset() {
    filters.query = "";
  }

  const debouncedFn = useDebounceFn(() => {
    fetchAuthors();
  }, 500);

  watch(
    filters,
    () => {
      // maybe solvable with some kind of type-conversion
      debouncedFn();
      router.push({ query: { ...route.query, ...filters } });
    },
    { deep: true }
  );

  const filters_for_api = computed(() => {
    const deepClone = _.cloneDeep(filters);
    deepClone.lang = getLocale();
    return deepClone;
  });

  async function getAuthorById(id: string) {
    try {
      const { data, error } = await useFetch(`/api/author/${id}`);
      if (data?.value?.error) {
        throw data.value;
      }
      author.value = zAuthor.parse(data.value as Author);
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

  async function fetchAuthorsByPublication(id: string) {
    try {
      const { data, error } = await useFetch(`/api/author/publication/${id}`);
      if (data?.value?.error) {
        throw data.value;
      }
      authorsByPublication.value = zAuthorResultList.parse(data.value).data;
    } catch (error) {
      if (error instanceof ZodError) {
        console.log(error);
        const new_error = { code: "666", message: "ZodError", data: error };

        console.log("Something went wrong: fetchAuthorsByPublication from Zod");
      } else {
        console.log("Something went wrong: fetchAuthorsByPublication");
      }
    }
  }

  async function fetchAuthors() {
    try {
      pendingAuthors.value = true;
      const { data, error } = await useFetch("/api/author/authors", {
        params: { ...filters_for_api.value },
      });
      if (data?.value?.error) {
        throw data.value;
      }
      authors.value = zAuthorResultList.parse(data.value).data;
      authorsMeta.value.showing = zAuthorResultList.parse(data.value).showing;
      authorsMeta.value.total = zAuthorResultList.parse(data.value).total;
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

  function paramsSerializer(params: any) {
    //https://github.com/unjs/ufo/issues/62
    if (!params) {
      return;
    }
    Object.entries(params).forEach(([key, val]) => {
      if (typeof val === "object" && Array.isArray(val) && val !== null) {
        params[key + "[]"] = val.map((v) => JSON.stringify(v));
        delete params[key];
      }
    });
  }

  return {
    authors,
    authorsByPublication,
    authorsMeta,
    author,
    filters,
    errorAuthors,
    pendingAuthors,
    getAuthorById,
    fetchAuthors,
    fetchAuthorsByPublication,
  };
});
