import { unref, reactive, watch, computed, ref } from "vue";
import "hookable";
import { u as useFetch } from "./Spinner-cea46663.js";
import "destr";
import { h as defineStore, u as useI18n, d as useRoute, b as useRouter, s as storeToRefs } from "../server.mjs";
import _ from "lodash";
const noop = () => {
};
function resolveUnref(r) {
  return typeof r === "function" ? r() : unref(r);
}
function createFilterWrapper(filter, fn) {
  function wrapper(...args) {
    return new Promise((resolve, reject) => {
      Promise.resolve(filter(() => fn.apply(this, args), { fn, thisArg: this, args })).then(resolve).catch(reject);
    });
  }
  return wrapper;
}
function debounceFilter(ms, options = {}) {
  let timer;
  let maxTimer;
  let lastRejector = noop;
  const _clearTimeout = (timer2) => {
    clearTimeout(timer2);
    lastRejector();
    lastRejector = noop;
  };
  const filter = (invoke) => {
    const duration = resolveUnref(ms);
    const maxDuration = resolveUnref(options.maxWait);
    if (timer)
      _clearTimeout(timer);
    if (duration <= 0 || maxDuration !== void 0 && maxDuration <= 0) {
      if (maxTimer) {
        _clearTimeout(maxTimer);
        maxTimer = null;
      }
      return Promise.resolve(invoke());
    }
    return new Promise((resolve, reject) => {
      lastRejector = options.rejectOnCancel ? reject : resolve;
      if (maxDuration && !maxTimer) {
        maxTimer = setTimeout(() => {
          if (timer)
            _clearTimeout(timer);
          maxTimer = null;
          resolve(invoke());
        }, maxDuration);
      }
      timer = setTimeout(() => {
        if (maxTimer)
          _clearTimeout(maxTimer);
        maxTimer = null;
        resolve(invoke());
      }, duration);
    });
  };
  return filter;
}
function useDebounceFn(fn, ms = 200, options = {}) {
  return createFilterWrapper(debounceFilter(ms, options), fn);
}
const useFilterStore = defineStore("filterStore", () => {
  const { getLocale } = useI18n();
  const route = useRoute();
  const router = useRouter();
  const getBoolean = (item) => {
    if (item === "false" || item === void 0) {
      return void 0;
    }
    return true;
  };
  const getNeedsAttentionBoolean = (item) => {
    if (item === "false") {
      return void 0;
    }
    return true;
  };
  const filters = reactive({
    needs_attention: getNeedsAttentionBoolean(route.query.needs_attention),
    scopus: getBoolean(route.query.scopus),
    wos: getBoolean(route.query.wos),
    manual: getBoolean(route.query.manual),
    pubtype: route.query.pubtype ? route.query.pubtype : "",
    title: route.query.title ? route.query.title : void 0
  });
  function $reset() {
    filters.needs_attention = true, filters.scopus = false, filters.wos = false, filters.manual = false, filters.pubtype = "", filters.title = void 0;
  }
  watch(
    filters,
    () => {
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
const useImportedPostsStore = defineStore("importedPostsStore", () => {
  const filterStore = useFilterStore();
  const { filters } = storeToRefs(filterStore);
  const importedPosts = ref([]);
  const importedPostById = ref(null);
  const errorImportedPostById = ref(null);
  const pendingImportedPosts = ref(null);
  const pendingImportedPostById = ref(null);
  const pendingRemoveImportedPost = ref(null);
  async function fetchImportedPosts() {
    try {
      pendingImportedPosts.value = true;
      console.log(filters.value);
      const { data, error } = await useFetch("/api/posts_imported", {
        params: { ...filters.value },
        onRequest({ request, options }) {
          paramsSerializer(options.params);
        }
      }, "$0hvUUXWFn4");
      importedPosts.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchImportedPosts");
    } finally {
      pendingImportedPosts.value = false;
    }
  }
  watch(
    filters,
    () => {
      fetchImportedPosts();
    },
    { deep: true }
  );
  async function fetchImportedPostById(id) {
    try {
      errorImportedPostById.value = null;
      pendingImportedPostById.value = true;
      const { data, error } = await useFetch(`/api/post_imported/${id}`, "$ZJQCfBpBYl");
      pendingImportedPostById.value = false;
      if (error.value) {
        errorImportedPostById.value = error.value.data;
        console.log("from fetchImportedPostById", errorImportedPostById);
      } else {
        importedPostById.value = data.value;
      }
    } catch (error) {
      console.log("Something went wrong: fetchImportedPostById");
    } finally {
      pendingImportedPostById.value = false;
    }
  }
  async function removeImportedPost(id) {
    try {
      pendingRemoveImportedPost.value = true;
      const { data, error } = useFetch(`/api/post_imported/${id}`, { method: "DELETE" }, "$hF1hi1sgmQ");
    } catch (error) {
      console.log("Something went wrong: removeImportedPost");
    } finally {
      pendingRemoveImportedPost.value = false;
    }
  }
  function paramsSerializer(params) {
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
  return { importedPosts, fetchImportedPosts, pendingImportedPosts, removeImportedPost, fetchImportedPostById, importedPostById, errorImportedPostById, pendingImportedPostById, pendingRemoveImportedPost };
});
export {
  useImportedPostsStore as a,
  useDebounceFn as b,
  useFilterStore as u
};
//# sourceMappingURL=imported_posts-1f7e588c.js.map
