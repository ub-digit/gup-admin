import { defineStore } from 'pinia'
import { useFilterStore } from '~/store/filter'
import { storeToRefs } from 'pinia'
export const useImportedPostsStore = defineStore('importedPostsStore', () => {
  const filterStore = useFilterStore();
  const {filters} = storeToRefs(filterStore);
  const users = ref(['xgrkri','xannje','xjopau']) 
  const selectedUser = ref("");
  const importedPosts = ref([])
  const importedPostById = ref(null);
  const errorImportedPostById = ref(null);
  const pendingImportedPosts= ref(null);
  const pendingImportedPostById = ref(null);
  const pendingRemoveImportedPost = ref(null);
  const pendingCreateImportedPostInGup = ref(null);

  async function createImportedPostInGup(id, user) {
    try {
      pendingCreateImportedPostInGup.value = true;
      const { data, error } = await useFetch(`/api/post_to_gup/${id}/`, {
          params: {"user": user},
        });
        return data.value;
    } catch (error) {
        console.log(error)
    }
    finally {
      pendingCreateImportedPostInGup.value = false;
    }
  }

  async function fetchImportedPosts() {
    try {
        pendingImportedPosts.value = true;
        const { data, error } = await useFetch("/api/posts_imported", {
            params: {...filters.value},
            onRequest({ request, options }) {
              paramsSerializer(options.params);
            }
          });
          importedPosts.value = data.value;
        } catch (error) {
          console.log("Something went wrong: fetchImportedPosts")
        }
        finally {
          
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
      const { data, error } = await useFetch(`/api/post_imported/${id}`)
      if (error.value) {
        errorImportedPostById.value = error.value.data.data.error;
        console.log("from fetchImportedPostById",errorImportedPostById)
      } else {
        importedPostById.value = data.value;
      }
    } catch (error) {
      console.log("Something went wrong: fetchImportedPostById")
    }
    finally {
      pendingImportedPostById.value = false;
    }

  }

  async function removeImportedPost(id) {
    try {
        pendingRemoveImportedPost.value = true;
        const { data, error } = await useFetch(`/api/post_imported/${id}`, {method: 'DELETE'})
        if (!data) {
          throw (error);
        }
        return data;
      } catch (error) {
        console.log(error.value.data.statusCode, error.value.data.statusMessage)
        return {error: error.value.data};
      }
    finally {
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
    importedPostById.value = null,
    errorImportedPostById.value = null;


  }
  return {createImportedPostInGup, importedPosts,fetchImportedPosts, pendingImportedPosts, removeImportedPost, 
        fetchImportedPostById, importedPostById, errorImportedPostById,  pendingImportedPostById, 
        pendingRemoveImportedPost, pendingCreateImportedPostInGup, $importedReset, users, selectedUser
    }
})