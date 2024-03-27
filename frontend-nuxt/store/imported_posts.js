import { defineStore } from "pinia";
import { useFilterStore } from "~/store/filter";
import { storeToRefs } from "pinia";
import nuxtStorage from "nuxt-storage";
export const useImportedPostsStore = defineStore("importedPostsStore", () => {
  const filterStore = useFilterStore();
  const { filters } = storeToRefs(filterStore);
  const users = ref([
    "xgrkri",
    "xannje",
    "xjopau",
    "xljoha",
    "xlpero",
    "xblars",
    "xberns",
    "xjostw",
  ]);
  const selectedUser = ref("");
  const selectedUserOverride = ref("");
  const importedPosts = ref([]);
  const numberOfImportedPostsTotal = ref(0);
  const numberOfImportedPostsShowing = ref(0);
  const importedPostById = ref(null);

  const errorImportedPostById = ref(null);
  const pendingImportedPosts = ref(null);
  const pendingImportedPostById = ref(null);
  const pendingRemoveImportedPost = ref(null);
  const pendingCreateImportedPostInGup = ref(null);

  if (
    nuxtStorage &&
    nuxtStorage.localStorage &&
    nuxtStorage.localStorage.getData("selectedUser")
  ) {
    selectedUser.value = nuxtStorage.localStorage.getData("selectedUser");
  }

  if (nuxtStorage?.localStorage?.getData("selectedUserOverride")) {
    selectedUserOverride.value = nuxtStorage.localStorage.getData(
      "selectedUserOverride"
    );
  }

  watch(selectedUser, () => {
    // save to localstorage
    nuxtStorage?.localStorage?.setData("selectedUser", selectedUser.value);
    if (selectedUser.value !== "") {
      selectedUserOverride.value = "";
    }
  });

  watch(selectedUserOverride, () => {
    // save to localstorage
    nuxtStorage?.localStorage?.setData(
      "selectedUserOverride",
      selectedUserOverride.value
    );
    if (selectedUserOverride.value?.length === 6) {
      selectedUser.value = "";
    }
  });

  const selectedUserComputed = computed(() => {
    if (selectedUser.value) {
      return selectedUser.value;
    }
    return selectedUserOverride.value;
  });
  async function createImportedPostInGup(id: string, user: string) {
    try {
      pendingCreateImportedPostInGup.value = true;
      const { data, error } = await useFetch(`/api/post_to_gup/${id}/`, {
        params: { user: user },
      });
      if (error.value) {
        throw error;
      }
      return data.value;
    } catch (error) {
      console.log(error);
      return { error: error.value.data };
    } finally {
      pendingCreateImportedPostInGup.value = false;
    }
  }

  async function mergePosts(id, gupid, user) {
    try {
      const { data, error } = await useFetch(`/api/merge_posts/`, {
        params: { id: id, gupid: gupid, user: user },
      });
      return data.value;
    } catch (error) {
      console.log(error);
      return error;
    } finally {
    }
  }

  async function fetchImportedPosts() {
    try {
      pendingImportedPosts.value = true;
      const { data, error } = await useFetch("/api/posts_imported", {
        params: { ...filters.value },
        onRequest({ request, options }) {
          paramsSerializer(options.params);
        },
      });
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
      importedPostById.value = null;
      pendingImportedPostById.value = true;
      errorImportedPostById.value = null;
      const { data, error } = await useFetch(`/api/post_imported/${id}`);
      if (data.value.error) {
        throw data.value;
      }
      importedPostById.value = data.value;
    } catch (error) {
      console.log(error);
      errorImportedPostById.value = error;
      console.log(error);
    } finally {
      pendingImportedPostById.value = false;
    }
  }

  async function removeImportedPost(id) {
    try {
      pendingRemoveImportedPost.value = true;
      const { data, error } = await useFetch(`/api/post_imported/${id}`, {
        method: "DELETE",
      });
      if (error.value) {
        throw error;
      }
      return data;
    } catch (error) {
      console.log(error.value.data.statusCode, error.value.data.statusMessage);
      return { error: error.value };
    } finally {
      pendingRemoveImportedPost.value = false;
    }
  }

  function paramsSerializer(params) {
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

  function $importedReset() {
    // manually reset store here
    (importedPostById.value = null), (errorImportedPostById.value = null);
  }
  return {
    createImportedPostInGup,
    importedPosts,
    fetchImportedPosts,
    pendingImportedPosts,
    removeImportedPost,
    mergePosts,
    fetchImportedPostById,
    importedPostById,
    errorImportedPostById,
    pendingImportedPostById,
    pendingRemoveImportedPost,
    pendingCreateImportedPostInGup,
    $importedReset,
    users,
    selectedUser,
    selectedUserOverride,
    selectedUserComputed,
  };
});
