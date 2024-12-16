import { ZodError } from "zod";
import { defineStore } from "pinia";
import { useFilterStore } from "~/store/filter";
import { storeToRefs } from "pinia";
import nuxtStorage from "nuxt-storage";
import type { Publication, AuthorAffiliation } from "~/types/Publication";
import {
  zPublicationArray,
  zAuthorAffiliationArray,
} from "~/types/Publication";
import type { ImportedPostType } from "~/types/PublicationCompareRow";
import { zImportedPostType } from "~/types/PublicationCompareRow";

export const useImportedPostsStore = defineStore("importedPostsStore", () => {
  const filterStore = useFilterStore();
  const { filters } = storeToRefs(filterStore);

  const { data: authData } = useAuth();

  const authorsByPublication: Ref<AuthorAffiliation[]> = ref([]);
  const selectedUser: Ref<string | null> = ref("");
  const selectedUserOverride: Ref<string> = ref("");
  const importedPosts: Ref<Publication[]> = ref([]);
  const importedPostsByAuthors: Ref<Publication[]> = ref([]);
  const numberOfImportedPostsTotal = ref(0);
  const numberOfImportedPostsShowing = ref(0);
  const numberOfImportedPostsByAuthorsTotal = ref(0);
  const numberOfImportedPostsByAuthorsShowing = ref(0);
  const importedPostById: Ref<ImportedPostType | null> = ref(null);
  const errorImportedPostById = ref(null);
  const pendingImportedPosts = ref(false);
  const pendingImportedPostById = ref(false);
  const pendingRemoveImportedPost = ref(false);
  const pendingCreateImportedPostInGup = ref(false);
  const pendingImportedPostsByAuthors = ref(false);

  watch(selectedUser, () => {
    // save to localstorage
    nuxtStorage?.localStorage?.setData("selectedUser", selectedUser.value);
    if (selectedUser.value !== "") {
      selectedUserOverride.value = "";
    }
  });

  async function createImportedPostInGup(id: string) {
    try {
      pendingCreateImportedPostInGup.value = true;
      const { data, error } = await useFetch(`/api/post_to_gup/${id}/`, {
        params: { user: authData?.value?.user?.name },
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

  async function mergePosts(id: string, gupid: string) {
    try {
      const { data, error } = await useFetch(`/api/merge_posts/`, {
        params: { id: id, gupid: gupid, user: authData?.value?.user?.name },
      });
      return data.value;
    } catch (error) {
      console.log(error);
      return error;
    } finally {
    }
  }

  async function fetchImportedPostsByAuthors(searchStr: string) {
    try {
      pendingImportedPostsByAuthors.value = true;
      const { data, error } = await useFetch("/api/posts_imported", {
        params: { title: searchStr },
        onRequest({ request, options }) {
          paramsSerializer(options.params);
        },
      });
      // maybe move to meta-object in response from backend
      importedPostsByAuthors.value = zPublicationArray.parse(data.value).data;
      numberOfImportedPostsByAuthorsTotal.value = zPublicationArray.parse(
        data.value
      ).total;
      numberOfImportedPostsByAuthorsShowing.value = zPublicationArray.parse(
        data.value
      ).showing;
    } catch (error) {
      if (error instanceof ZodError) {
        console.log("Something went wrong: fetchImportedPosts from Zod", error);
      } else {
        console.log("Something went wrong: fetchImportedPosts");
      }
    } finally {
      pendingImportedPostsByAuthors.value = false;
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
      // maybe move to meta-object in response from backend
      importedPosts.value = zPublicationArray.parse(data.value).data;
      numberOfImportedPostsTotal.value = zPublicationArray.parse(
        data.value
      ).total;
      numberOfImportedPostsShowing.value = zPublicationArray.parse(
        data.value
      ).showing;
    } catch (error) {
      if (error instanceof ZodError) {
        console.log("Something went wrong: fetchImportedPosts from Zod", error);
      } else {
        console.log("Something went wrong: fetchImportedPosts");
      }
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

  async function fetchImportedPostById(id: string) {
    try {
      importedPostById.value = null;
      pendingImportedPostById.value = true;
      errorImportedPostById.value = null;
      const { data, error } = await useFetch(`/api/post_imported/${id}`);
      if (data.value.error) {
        throw data.value;
      }
      importedPostById.value = zImportedPostType.parse(data.value);
    } catch (error) {
      console.log(error);
      errorImportedPostById.value = error;
      console.log(error);
    } finally {
      pendingImportedPostById.value = false;
    }
  }

  async function removeImportedPost(id: string) {
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

  async function fetchAuthorsByPublication(id: string) {
    try {
      const { data, error } = await useFetch(`/api/_author/publication/${id}`);
      if (data?.value?.error) {
        throw data.value;
      }
      authorsByPublication.value = zAuthorAffiliationArray.parse(
        data.value
      ).data;
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
  function addEmptyAuthorToPublication() {
    authorsByPublication.value.push({
      id: null,
      name: "Ny Författare",
      affiliation_str: "University of Oslo",
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
    fetchImportedPostsByAuthors,
    pendingImportedPostsByAuthors,
    importedPostsByAuthors,
    numberOfImportedPostsByAuthorsShowing,
    numberOfImportedPostsByAuthorsTotal,
    fetchAuthorsByPublication,
    addEmptyAuthorToPublication,
    authorsByPublication,
    numberOfImportedPostsTotal,
    numberOfImportedPostsShowing,
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
    selectedUser,
    selectedUserOverride,
  };
});
