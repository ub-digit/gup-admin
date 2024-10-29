import { defineStore } from "pinia";
import { ZodError, number } from "zod";
import { zOrganization, zOrganizationResultList } from "~/types/Organizations";
import type {
  Organization,
  OrganizationResultList,
} from "~/types/Organizations"; // needs type after import to avoid error
import _ from "lodash";
import { useDebounceFn } from "@vueuse/core";

export const useOrganizationsStore = defineStore("organizationsStore", () => {
  const { getLocale } = useI18n();
  const route = useRoute();
  const router = useRouter();

  const organizations: Ref<Organization[]> = ref([]);

  interface Meta {
    total: number;
    showing: number;
  }
  const organizationsMeta: Ref<Meta> = ref({ total: 0, showing: 0 });
  const organization: Ref<Organization | null> = ref(null);
  const errorOrganizations = ref({});
  const errorOrganization = ref({});
  const pendingOrganizations = ref(false);

  interface Filter {
    query: string;
  }
  const filters: Filter = reactive({
    query: route.query.query ? (route.query.query as string) : "",
  });

  function $reset() {
    filters.query = "";
  }

  const debouncedFn = useDebounceFn(() => {
    fetchOrganizations();
  }, 500);

  watch(
    filters,
    () => {
      // maybe solvable with some kind of type-conversion
      debouncedFn();
      router.push({ query: { ...route.query, ...filters } });
    },
    { deep: true }
  );

  const filters_for_api = computed(() => {
    const deepClone = _.cloneDeep(filters);
    deepClone.lang = getLocale();
    return deepClone;
  });

  async function fetchOrganizationById(id: string) {
    try {
      const { data, error } = await useFetch(`/api/organization/${id}`);
      if (data?.value?.error) {
        throw data.value;
      }
      organization.value = zOrganization.parse(data.value as any);
    } catch (error) {
      if (error instanceof ZodError) {
        const new_error = { code: "666", message: "ZodError", data: error };
        errorOrganization.value = new_error;
        console.log(errorOrganization.value);
        console.log("Something went wrong: getOrganizationById from Zod");
      } else {
        errorOrganization.value = error.error;
        console.log(errorOrganization.value);
        console.log("Something went wrong: getOrganizationById");
      }
    }
  }

  async function fetchOrganizations() {
    try {
      pendingOrganizations.value = true;
      const { data, error } = await useFetch(
        "/api/organization/organizations",
        {
          params: { ...filters_for_api.value },
        }
      );
      if (data?.value?.error) {
        throw data.value;
      }
      organizations.value = zOrganizationResultList.parse(data.value).data;
      organizationsMeta.value.showing = zOrganizationResultList.parse(
        data.value
      ).showing;
      organizationsMeta.value.total = zOrganizationResultList.parse(
        data.value
      ).total;
    } catch (error) {
      if (error instanceof ZodError) {
        const new_error = { code: "666", message: "ZodError", data: error };
        errorOrganizations.value = new_error;
        console.log(errorOrganizations.value);
        console.log("Something went wrong: fetchOrganizations from Zod");
      } else {
        errorOrganizations.value = error.error;
        console.log(errorOrganizations.value);
        console.log("Something went wrong: fetchOrganizations");
      }
    } finally {
      pendingOrganizations.value = false;
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

  return {
    organizations,
    organizationsMeta,
    organization,
    filters,
    errorOrganizations,
    pendingOrganizations,
    fetchOrganizationById,
    fetchOrganizations,
  };
});
