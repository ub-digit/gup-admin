import { defineStore } from 'pinia'

export const useGupPostsStore = defineStore('gupPostsStore', () => {
  const gupPostsByTitle = ref([])
  const gupPostsById = ref([])
  const gupPostById = ref({});
  const gupCompareImportedMatrix = ref({});
  const errorGupPostById = ref(null);
  const pendingGupPostsByTitle= ref(null);
  const pendingGupPostsById= ref(null);
  const pendingGupPostById= ref(null);
  
  
  async function fetchCompareGupPostWithImported(importedID, GupID) {
    gupCompareImportedMatrix.value = [
      
      { "first": { "value": "gup:319932" }, "second": { "value": "gup:319932"}, "diff": false, "display_type": "string", "visibility": "never", "display_label": "id" },
      { "first": { "value": 319932}, "second": { "value": 319932}, "diff": false, "display_type": "string", "visibility": "never", "display_label": "publication_id"  },

      { "first": { "value": { "title": "Cluelessness and rational choice: the case of effective altruism", "url": null} }, "second": {"value": { "title": "Cluelessness and rational choice: the case of effective altruism", "url": "http://gup.ub.gu.se/23423"}}, "diff": false, "display_type": "title", "visibility": "always", "display_label": "title" },

      { "first": { "value": {"attended": {"value": false, "display_label": "attended"}, "created_at": {"value": '2022-11-14T22:42:32.030Z', "display_label": "created_at"}, "version_created_by": {"value": "xherli", "display_label": "version_created_by"}, "updated_at": {"value": "2022-11-18T13:31:28.143Z", "display_label": "updated_at" }, "version_updated_by": {"value": "xrewkl", "display_label": "version_updated_by"}, "source": {"value": "gup", "display_label": "source" } }}, "second": { "value": {"attended": {"value": true, "display_label": "attended"}, "created_at": {"value": '2022-11-14T22:42:32.030Z', "display_label": "created_at"}, "version_created_by": {"value": "xherli", "display_label": "version_created_by"}, "updated_at": {"value": "2022-11-18T13:31:28.143Z", "display_label": "updated_at" }, "version_updated_by": {"value": "xrewkl", "display_label": "version_updated_by"}, "source": {"value": "gup", "display_label": "source" } }}, "display_type": "meta", "visibility": "always"
      },

      { "first": { "value": "Artikel i vetenskaplig tidskrift"}, "second": { "value": "Artikel i vetenskaplig tidskrift"}, "diff": false, "display_type": "string", "visibility": "always", "display_label": "publication_type_label"},

      { "first": { "value": "Ethical Perspectives"}, "second": { "value": "Ethical Perspectives"}, "diff": false, "display_type": "string", "visibility": "always", "display_label": "sourcetitle" },

      { "first": { "value": 2019}, "second": { "value": 2019}, "diff": true, "display_type": "string", "visibility": "always", "display_label": "pubyear"  },

      { "first": {"value": {"sourcevolume": "26", "sourceissue": "2", "sourcepages": "401-426"}},
      "second": {"value": {"sourcevolume": "26", "sourceissue": "2", "sourcepages": "401-426"}},
      "diff": true, 
      "display_type": "sourceissue_sourcepages_sourcevolume",
      "visibility": "always",
      "display_label": "sourceissue_sourcepages_sourcevolume"
      },

      { "first": { "value": [
            {
              "id": 1090495,
              "name": "Anders Herlitz",
              "x-account": "xherli"
            },
            {
            "id": 1090422295,
            "name": "Anders Herlitz 1",
            "x-account": "xherli"
            },
            {
            "id": 144090495,
            "name": "Anders Herlitz 3",
            "x-account": "xherli"
            },
            {
            "id": 10555590495,
            "name": "Anders Herlitz 4",
            "x-account": "xherli"
            }
          ]
        }, 
        "second": { "value": [
            {
              "id": 1090495,
              "name": "Anders Herlitz",
              "x-account": "xherli"
            },
            {
            "id": 1090422295,
            "name": "Anders Herlitz 1",
            "x-account": "xherli"
            },
            {
            "id": 144090495,
            "name": "Anders Herlitz 3",
            "x-account": "xherli"
            },
            {
            "id": 10555590495,
            "name": "Anders Herlitz 4",
            "x-account": "xherli"
            }
          ]
        }, 
        "diff": false, 
        "display_type": "authors",
        "visibility": "always",
        "display_label": "authors"
      },
      { "first": { "value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "second": {"value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "diff": false, "display_type": "url", "visibility": "always", "display_label": "scopus"},
      { "first": { "value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "second": {"value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "diff": false, "display_type": "url", "visibility": "always", "display_label": "isiid"},
      { "first": { "value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "second": {"value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "345435"}}, "diff": true, "display_type": "url", "visibility": "always", "display_label": "doi"},
    ]
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