import { ref, type Ref } from "vue";
import { defineStore } from "pinia";
import { ZodError } from "zod";
import type { Department } from "~/types/Department";
import { zDepartmentArray, zDepartment } from "~/types/Department";

export const useDepartmentStore = defineStore("DepartmentStore", () => {
  const route = useRoute();
  const router = useRouter();
  const departments: Ref<Department[]> = ref([]);
  const department: Ref<Department | null> = ref(null);
  const numberOfDepartmentsTotal = ref(0);
  const numberOfDepartmentsShowing = ref(0);
  const pendingDepartments = ref(false);

  interface Filter {
    query: string | undefined;
  }

  const filter: Filter = reactive({
    query: route.query.query as string,
  });

  const createDepartment = async (department: Department) => {
    try {
      const { data, error } = await useFetch("/api/departments/", {
        method: "POST",
        body: department,
      });
      if (data?.value?.success?.data.status === "ok") {
        return {
          status: "success",
          errors: [],
        };
      } else if (data?.value?.errors.validation.length > 0) {
        return { status: "error", errors: data?.value?.errors?.validation };
      }
    } catch (error) {
      console.log("Something went wrong: createDepartment", error);
    }
  };

  const updateDepartment = async (id: string, department: Department) => {
    try {
      const { data, error } = await useFetch(`/api/departments/${id}`, {
        method: "PUT",
        body: department,
      });
      if (data?.value?.success?.data.status === "ok") {
        return {
          status: "success",
          errors: [],
        };
      } else if (data?.value?.errors.validation.length > 0) {
        return { status: "error", errors: data?.value?.errors?.validation };
      }
    } catch (error) {
      console.log("Something went wrong: updateDepartment", error);
    }
  };

  const fetchDepartment = async (id: string) => {
    try {
      const { data, error } = await useFetch(`/api/departments/${id}/`);
      if (error.value) {
        throw error;
      }
      department.value = zDepartment.parse(data.value);
    } catch (error) {
      if (error instanceof ZodError) {
        console.log("Something went wrong: fetchDepartment from Zod", error);
      } else {
        console.log("Something went wrong: fetchDepartment");
      }
    }
  };

  const fetchDepartments = async (searchStr: string) => {
    try {
      filter.query = searchStr;
      pendingDepartments.value = true;
      const { data, error } = await useFetch("/api/departments/suggest/", {
        params: { query: searchStr },
        onRequest({ request, options }) {
          paramsSerializer(options.params);
        },
      });

      if (error.value) {
        throw error;
      }
      departments.value = zDepartmentArray.parse(data.value).data;
      numberOfDepartmentsTotal.value = zDepartmentArray.parse(data.value).total;
      numberOfDepartmentsShowing.value = zDepartmentArray.parse(
        data.value
      ).showing;
    } catch (error) {
      if (error instanceof ZodError) {
        console.log("Something went wrong: fetchDepartments from Zod", error);
      } else {
        console.log("Something went wrong: fetchDepartments");
      }
    } finally {
      pendingDepartments.value = false;
    }
  };

  watch(
    filter,
    () => {
      // maybe solvable with some kind of type-conversion
      router.push({ query: { ...route.query, ...filter } });
    },
    { deep: true }
  );

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
    fetchDepartments,
    fetchDepartment,
    updateDepartment,
    createDepartment,
    departments,
    pendingDepartments,
    numberOfDepartmentsTotal,
    numberOfDepartmentsShowing,
    department,
    filter,
  };
});
