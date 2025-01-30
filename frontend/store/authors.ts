import { defineStore } from "pinia";
import { ZodError, number } from "zod";
import { zAuthorArray, zAuthor, zAuthorResultList } from "~/types/Author";
//import { zAuthorAffiliationArray } from "~/types/Publication";
import { zIdentifierArray } from "~/types/Identifier";
import type { Identifier } from "~/types/Identifier";
import type { AuthorAffiliation } from "~/types/Publication";
import type { Author } from "~/types/Author"; // needs type after import to avoid error
import _ from "lodash";
import { useDebounceFn } from "@vueuse/core";

export const useAuthorsStore = defineStore("authorsStore", () => {
  const { getLocale } = useI18n();
  const route = useRoute();
  const router = useRouter();

  const authorsByPublication: Ref<AuthorAffiliation[]> = ref([]);
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

  const identifiers: Ref<Identifier[]> = ref([]);
  const errorIdentifiers = ref({});

  const getBoolean = (item: string): boolean | undefined => {
    if (item === "false") {
      return false;
    }
    return true;
  };
  interface Filter {
    query: string;
    isMerged: boolean;
  }
  const filters: Filter = reactive({
    query: route.query.query ? (route.query.query as string) : "",
    isMerged: route.query.isMerged
      ? getBoolean(route.query.isMerged as string)
      : false,
  });

  function $reset() {
    filters.query = "";
    filters.isMerged = false;
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

  async function fetchIdentifiers() {
    try {
      const { data, error } = await useFetch("/api/_author/identifiers");
      if (data?.value?.error) {
        throw data.value;
      }
      identifiers.value = zIdentifierArray.parse(data.value);
    } catch (error) {
      if (error instanceof ZodError) {
        const new_error = { code: "666", message: "ZodError", data: error };
        errorIdentifiers.value = new_error;
        console.log(errorIdentifiers.value);
        console.log("Something went wrong: getIdentifiers from Zod");
      } else {
        errorIdentifiers.value = error.error;
        console.log(errorIdentifiers.value);
        console.log("Something went wrong: getIdentifiers");
      }
    }
  }
  async function fetchAuthorById(id: string) {
    try {
      const { data, error } = await useFetch(`/api/_author/${id}`);
      if (data?.error?.value) {
        throw data?.error?.value;
      }
      console.log(data?.value.success.data);
      author.value = zAuthor.parse(data.value.success.data as Author);
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
      const { data, error } = await useFetch("/api/_author/authors", {
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

  const updateAuthor = async (id: string, author: Author) => {
    try {
      const { data, error } = await useFetch(`/api/_author/${id}`, {
        method: "PUT",
        body: author,
      });
      if (data?.value?.success?.data.status === "ok") {
        return {
          status: "success",
          errors: [],
        };
      } else if (data?.value?.errors.validation.length > 0) {
        return { status: "error", errors: data?.value?.errors?.validation };
      }
    } catch (error) {
      console.log("Something went wrong: updateAuthor", error);
    }
  };

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
    $reset,
    filters,
    errorAuthors,
    pendingAuthors,
    fetchAuthorById,
    fetchAuthors,
    updateAuthor,
    fetchIdentifiers,
    identifiers,
    errorIdentifiers,
  };
});
