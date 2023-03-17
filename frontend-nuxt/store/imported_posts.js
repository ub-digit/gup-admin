import { defineStore } from 'pinia'
import { useFilterStore } from '~/store/filter'
import { storeToRefs } from 'pinia'
export const useImportedPostsStore = defineStore('importedPostsStore', () => {
  const filterStore = useFilterStore();
  const {filters} = storeToRefs(filterStore);

  const importedPosts = ref([])
  const importedPostById = ref(null);
  const errorImportedPostById = ref(null);
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
      errorImportedPostById.value = null;
      pendingImportedPostById.value = true;
      const { data, error } = await  useFetch(`/api/post_imported/${id}`)
      pendingImportedPostById.value = false;
      if (error.value) {
        errorImportedPostById.value = error.value.data;
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
        const { data, error } = useFetch(`/api/post_imported/${id}`, {method: 'DELETE'})
      } catch (error) {
        console.log("Something went wrong: removeImportedPost")
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


  function $reset() {
    // manually reset store here
  }
  return { importedPosts,fetchImportedPosts, pendingImportedPosts, removeImportedPost, fetchImportedPostById, importedPostById, errorImportedPostById,  pendingImportedPostById, pendingRemoveImportedPost}
})