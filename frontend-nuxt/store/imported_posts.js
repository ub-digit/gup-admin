import { defineStore } from 'pinia'
import { useFilterStore } from '~/store/filter'
import { storeToRefs } from 'pinia'
export const useImportedPostsStore = defineStore('importedPostsStore', () => {
  const filterStore = useFilterStore();
  const {filters, filters_for_api} = storeToRefs(filterStore);

  const importedPosts = ref([])
  const importedPostById = ref({});
  const pendingImportedPosts= ref(null);
  const pendingImportedPostById = ref(null);
  const pendingRemoveImportedPost = ref(null);
  async function fetchImportedPosts() {
    try {
        pendingImportedPosts.value = true;
        console.log(filters.value)
        const { data, error } = await useFetch("/api/posts_imported", {
            params: {...filters.value},
            onRequest({ request, options }) {
              paramsSerializer(options.params);
            }
          });
      pendingImportedPosts.value = false;
      importedPosts.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchImportedPosts")
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
      pendingImportedPostById.value = true;
      const { data, error } = await  useFetch(`/api/post_imported/${id}`)
      pendingImportedPostById.value = false;
      importedPostById.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchImportedPostById")
    }

  }

  async function removeImportedPost(id) {
    try {
        pendingRemoveImportedPost.value = true;
        const { data, error } = useFetch(`/api/post_imported/${id}`, {method: 'DELETE'})
        pendingRemoveImportedPost.value = false;
    } catch (error) {
      console.log("Something went wrong: removeImportedPost")
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


  function $reset() {
    // manually reset store here
  }
  return { importedPosts,fetchImportedPosts, pendingImportedPosts, removeImportedPost, fetchImportedPostById, importedPostById, pendingImportedPostById, pendingRemoveImportedPost}
})