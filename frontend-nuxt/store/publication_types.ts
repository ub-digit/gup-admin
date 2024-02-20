import { defineStore } from "pinia";
import type { PublicationType } from "~/types/PublicationType";

export const usePublicationTypesStore = defineStore(
  "publicationTypesStore",
  () => {
    const publicationTypes: Ref<PublicationType[]> = ref([]);
    const pendingPublicationTypes = ref(false);

    async function fetchPublicationTypes(params: { lang: string }) {
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