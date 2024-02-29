import { defineStore } from "pinia";
import { ZodError } from "zod";
import {
  zPublicationCompareArray,
  type PublicationType,
} from "~/types/PublicationType";

export const usePublicationTypesStore = defineStore(
  "publicationTypesStore",
  () => {
    const publicationTypes: Ref<PublicationType[]> = ref([]);
    const pendingPublicationTypes = ref(false);

    async function fetchPublicationTypes(params: { lang: string }) {
      try {
        pendingPublicationTypes.value = true;
        const { data: publication_types, error } = await useFetch(
          "/api/publication_types",
          {
            params,
          }
        );
        publicationTypes.value = zPublicationCompareArray.parse(
          publication_types.value
        );
      } catch (error) {
        if (error instanceof ZodError) {
          console.log("Something went wrong: fetchPublicationTypes from Zod");
        } else {
          console.log("Something went wrong: fetchPublicationTypes");
        }
      } finally {
        pendingPublicationTypes.value = false;
      }
    }

    function $reset() {
      // manually reset store here
    }
    return { publicationTypes, fetchPublicationTypes, pendingPublicationTypes };
  }
);
