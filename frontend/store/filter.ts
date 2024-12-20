import { defineStore } from "pinia";
import _ from "lodash";

export const useFilterStore = defineStore("filterStore", () => {
  const { getLocale } = useI18n();
  const route = useRoute();
  console.log(route.query);
  const router = useRouter();
  const getBoolean = (item: string): boolean | undefined => {
    if (item === "false" || item === undefined) {
      return undefined;
    }
    return true;
  };

  const getNeedsAttentionBoolean = (item: string): boolean | undefined => {
    if (item === "false") {
      return false;
    }
    return true;
  };

  interface Filter {
    needs_attention: boolean | undefined;
    scopus: boolean | undefined;
    wos: boolean | undefined;
    manual: boolean | undefined;
    pubtype: string;
    query: string | undefined;
    year: string;
  }

  const filters: Filter = reactive({
    needs_attention: getNeedsAttentionBoolean(
      route.query.needs_attention as string
    ),
    scopus: getBoolean(route.query.scopus as string),
    wos: getBoolean(route.query.wos as string),
    manual: getBoolean(route.query.manual as string),
    pubtype: (route.query.pubtype as string)
      ? (route.query.pubtype as string)
      : "",
    query: (route.query.query as string)
      ? (route.query.query as string)
      : undefined,
    year: (route.query.year as string) ? (route.query.year as string) : "",
  });

  function $reset() {
    (filters.needs_attention = true),
      (filters.scopus = false),
      (filters.wos = false),
      (filters.manual = false),
      (filters.pubtype = ""),
      (filters.query = undefined),
      (filters.year = "");
  }

  watch(
    filters,
    () => {
      // maybe solvable with some kind of type-conversion
      router.push({ query: { ...route.query, ...filters } });
    },
    { deep: true }
  );

  const filters_for_api = computed(() => {
    const deepClone = _.cloneDeep(filters);
    deepClone.lang = getLocale();
    return deepClone;
  });

  return { filters, filters_for_api, $reset };
});
