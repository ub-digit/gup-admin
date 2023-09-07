import { defineStore } from "pinia";
import _ from "lodash";

export const useFilterStore = defineStore("filterStore", () => {
  const { getLocale } = useI18n();
  const route = useRoute();
  const router = useRouter();
  const getBoolean = (item) => {
    if (item === "false" || item === undefined) {
      return undefined;
    }
    return true;
  };

  const getNeedsAttentionBoolean = (item) => {
    if (item === "false") {
      return undefined;
    }
    return true;
  };

  const filters = reactive({
    needs_attention: getNeedsAttentionBoolean(route.query.needs_attention),
    scopus: getBoolean(route.query.scopus),
    wos: getBoolean(route.query.wos),
    manual: getBoolean(route.query.manual),
    pubtype: route.query.pubtype ? route.query.pubtype : "",
    title: route.query.title ? route.query.title : undefined,
    year: route.query.year ? route.query.year : "",
  });

  function $reset() {
    (filters.needs_attention = true),
      (filters.scopus = false),
      (filters.wos = false),
      (filters.manual = false),
      (filters.pubtype = ""),
      (filters.title = undefined),
      (filters.year = "");
  }

  watch(
    filters,
    () => {
      router.push({ query: { ...route.query, ...filters } });
    },
    { deep: true },
  );

  const filters_for_api = computed(() => {
    const deepClone = _.cloneDeep(filters);
    deepClone.lang = getLocale();
    return deepClone;
  });

  return { filters, filters_for_api, $reset };
});
