import { defineStore } from "pinia";
import { ZodError } from "zod";
import { zPublicationArray, type Publication } from "~/types/Publication";
import type { PublicationCompareRow } from "~/types/PublicationCompareRow";
import { zPublicationCompareRowArray } from "~/types/PublicationCompareRow";

export const useComparePostsStore = defineStore("comparePostsStore", () => {
  const gupPostsByTitle: Ref<Publication[]> = ref([]);
  const gupPostsById: Ref<Publication[]> = ref([]);
  const postsCompareMatrix: Ref<PublicationCompareRow[]> = ref([]);
  const errorPostsCompareMatrix = ref({});
  const pendingComparePost = ref(false);
  const pendingGupPostsByTitle = ref(false);
  const pendingGupPostsById = ref(false);

  async function fetchComparePostsMatrix(importedID: string, GupID: string) {
    try {
      pendingComparePost.value = true;
      const { data, error } = await useFetch("/api/post_gup_compare", {
        params: { imported_id: importedID, gup_id: GupID },
      });
      if (data.value.error) {
        throw data.value;
      }
      postsCompareMatrix.value = zPublicationCompareRowArray.parse(
        data.value.data
      );
    } catch (error) {
      // specific error handling for zoderror
      if (error instanceof ZodError) {
        // construct new error Lars format
        const new_error = { code: "666", message: "ZodError", data: error };
        errorPostsCompareMatrix.value = new_error;
        console.log(errorPostsCompareMatrix.value);
        console.log(
          "Something went wrong: fetchCompareGupPostWithImported from Zod"
        );
      } else {
        errorPostsCompareMatrix.value = error.error;
        console.log(errorPostsCompareMatrix.value);
        console.log("Something went wrong: fetchCompareGupPostWithImported");
      }
    } finally {
      pendingComparePost.value = false;
    }
  }

  async function fetchGupPostsById(id: string) {
    try {
      pendingGupPostsById.value = true;
      const { data, error } = await useFetch("/api/posts_duplicates", {
        params: { id: id, mode: "id" },
      });
      gupPostsById.value = zPublicationArray.parse(data.value).data;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsById");
    } finally {
      pendingGupPostsById.value = false;
    }
  }

  async function fetchGupPostsByTitle(id: string, title: string) {
    try {
      pendingGupPostsByTitle.value = true;
      const { data, error } = await useFetch("/api/posts_duplicates", {
        params: { id: id, title: title, mode: "title" },
      });
      gupPostsByTitle.value = data.value as Publication[];
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

  function $reset() {
    // manually reset store here
    // gupPostsByTitle.value = []
    // gupPostsById.value = []
    postsCompareMatrix.value = [];
    errorPostsCompareMatrix.value = {};
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
