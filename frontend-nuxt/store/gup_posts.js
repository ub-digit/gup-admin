import { defineStore } from 'pinia'

export const useGupPostsStore = defineStore('gupPostsStore', () => {
  const gupPostsByTitle = ref([])
  const gupPostsById = ref([])
  const gupPostById = ref({});
  const gupCompareImportedMatrix = ref({});
  const errorGupPostById = ref(null);
  const pendingCompareGupPostWithImported = ref(null)
  const pendingGupPostsByTitle= ref(null);
  const pendingGupPostsById= ref(null);
  const pendingGupPostById= ref(null);
  
  
  async function fetchCompareGupPostWithImported(importedID, GupID) {
    try {
      pendingCompareGupPostWithImported.value = true;
      const { data, error } = await useFetch("/api/post_gup_compare", {
          params: {"imported_id": importedID, "gup_id": GupID}
      });
      gupCompareImportedMatrix.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchCompareGupPostWithImported")
    }
    finally {
      pendingCompareGupPostWithImported.value = false;
    }

  }

  async function fetchGupPostsById(id) {
    try {
      pendingGupPostsById.value = true;
      const { data, error } = await useFetch("/api/posts_gup_by_id", {
          params: {"id": id}
      });
      gupPostsById.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsById")
    }
    finally {
      pendingGupPostsById.value = false;
    }
  }


  async function fetchGupPostsByTitle(id, title) {
    try {
      pendingGupPostsByTitle.value = true;
      const { data, error } = await useFetch("/api/posts_gup_by_title", {
            params: {"id": id, "title": title }
          });
      gupPostsByTitle.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsByTitle")
    }
    finally {
      pendingGupPostsByTitle.value = false;
    }

  }


  async function fetchGupPostById(id) {
    try {
      pendingGupPostById.value = true;
      const { data, error } = await  useFetch(`/api/post_gup/${id}`)
      if (error.value) {
        errorGupPostById.value =  error.value.data.data.error;;
      } else {
        gupPostById.value = data.value;
      }
    } catch (error) {
      //return createError({ statusCode: 404, statusMessage: 'Post Not Found' })
      console.log("Something went wrong: fetchGupPostById")
    }
    finally {
      pendingGupPostById.value = false;
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
   // gupPostsByTitle.value = []
   // gupPostsById.value = []
    gupPostById.value = {};
    errorGupPostById.value = null;
 //   pendingGupPostsByTitle.value = null;
   // pendingGupPostsById.value = null;
    pendingGupPostById.value = null;
  }
  return { gupPostsByTitle,fetchGupPostsByTitle, pendingGupPostsByTitle, gupPostsById,fetchGupPostsById, 
    pendingGupPostsById, gupPostById, errorGupPostById, fetchGupPostById, 
    pendingGupPostById, fetchCompareGupPostWithImported, gupCompareImportedMatrix, $reset
  }
})