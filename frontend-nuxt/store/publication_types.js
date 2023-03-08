import { defineStore } from 'pinia'

export const usePublicationTypesStore = defineStore('publicationTypesStore', () => {
  const publicationTypes = ref([])
  const pendingPublicationTypes = ref(null);

  async function fetchPublicationTypes() {
    try {
      pendingPublicationTypes.value = true;
      const {data, pending, error} = await useFetch("/api/pubtypes", {
      });
      pendingPublicationTypes.value = false;
      publicationTypes.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchPublicationTypes")
    }

  }


  function $reset() {
    // manually reset store here
  }
  return { publicationTypes,fetchPublicationTypes, pendingPublicationTypes}
})