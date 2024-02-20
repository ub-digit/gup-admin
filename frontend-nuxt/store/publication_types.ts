import { defineStore } from "pinia";

export const usePublicationTypesStore = defineStore(
  "publicationTypesStore",
  () => {
    const publicationTypes = ref([]);
    const pendingPublicationTypes = ref(false);

    async function fetchPublicationTypes(params) {
      try {
        pendingPublicationTypes.value = true;
        const { data, error } = await useFetch("/api/publication_types", {
          params,
        });
        pendingPublicationTypes.value = false;
        publicationTypes.value = data.value.publication_types;
      } catch (error) {
        console.log("Something went wrong: fetchPublicationTypes");
      }
    }

    function $reset() {
      // manually reset store here
    }
    return { publicationTypes, fetchPublicationTypes, pendingPublicationTypes };
  }
);
