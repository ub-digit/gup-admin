import { defineStore } from "pinia";

export const useComparePostsStore = defineStore("comparePostsStore", () => {
  const gupPostsByTitle = ref([]);
  const gupPostsById = ref([]);
  const postsCompareMatrix = ref({});
  const errorPostsCompareMatrix = ref(null);
  const pendingComparePost = ref(null);
  const pendingGupPostsByTitle = ref(null);
  const pendingGupPostsById = ref(null);

  async function fetchComparePostsMatrix(importedID, GupID) {
    try {
      pendingComparePost.value = true;
      const { data, error } = await useFetch("/api/post_gup_compare", {
        params: { imported_id: importedID, gup_id: GupID },
      });
      if (data.value.error) {
        throw data.value;
      }
      postsCompareMatrix.value = data.value;
    } catch (error) {
      errorPostsCompareMatrix.value = error;
      console.log(errorPostsCompareMatrix.value);
      console.log("Something went wrong: fetchCompareGupPostWithImported");
    } finally {
      pendingComparePost.value = false;
    }
  }

  async function fetchGupPostsById(id) {
    try {
      pendingGupPostsById.value = true;
      const { data, error } = await useFetch("/api/posts_duplicates", {
        params: { id: id, mode: "id" },
      });
      gupPostsById.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsById");
    } finally {
      pendingGupPostsById.value = false;
    }
  }

  async function fetchGupPostsByTitle(id, title) {
    try {
      pendingGupPostsByTitle.value = true;
      const { data, error } = await useFetch("/api/posts_duplicates", {
        params: { id: id, title: title, mode: "title" },
      });
      gupPostsByTitle.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsByTitle");
    } finally {
      pendingGupPostsByTitle.value = false;
    }
  }

  /*   async function fetchGupPostById(id) {
    try {
      pendingGupPostById.value = true;
      const { data, error } = await useFetch(`/api/post_imported/${id}`);
      if (error.value) {
        errorGupPostById.value = error.value.data.data.error;
      } else {
        gupPostById.value = data.value;
      }
    } catch (error) {
      //return createError({ statusCode: 404, statusMessage: 'Post Not Found' })
      console.log("Something went wrong: fetchGupPostById");
    } finally {
      pendingGupPostById.value = false;
    }
  } */

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

  function $reset() {
    // manually reset store here
    // gupPostsByTitle.value = []
    // gupPostsById.value = []
    postsCompareMatrix.value = null;
    errorPostsCompareMatrix.value = null;
    //   pendingGupPostsByTitle.value = null;
    // pendingGupPostsById.value = null;
  }
  return {
    gupPostsByTitle,
    fetchGupPostsByTitle,
    pendingGupPostsByTitle,
    gupPostsById,
    fetchGupPostsById,
    pendingGupPostsById,
    fetchComparePostsMatrix,
    errorPostsCompareMatrix,
    postsCompareMatrix,
    pendingComparePost,
    $reset,
  };
});
