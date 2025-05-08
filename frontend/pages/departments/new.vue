<template>
  <div v-if="department" class="row">
    <div class="col">
      <h2>Skapa ny institution</h2>

      <DepartmentForm
        :department="department"
        :errors="errors"
        @submit="saveDepartment"
        @onCancel="cancelEdit"
      />

      <div>debug</div>
      {{ department }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useDepartmentStore } from "~/store/departments";
import _ from "lodash";
import type { Department } from "~/types/Department";
const route = useRoute();
const router = useRouter();

const departmentStore = useDepartmentStore();

//const { department } = storeToRefs(departmentStore);

const department: Department = reactive({
  id: null,
  name_sv: "",
  name_en: "",
  start_year: null,
  end_year: null,
  orgnr: "",
  orgdbid: "",
  is_faculty: false,
  parentid: null,
});
const { updateDepartment, createDepartment, fetchDepartments } =
  departmentStore;
const errors: Ref<string[]> = ref([]);

// deepclone object to use in form v-model
//const organizationFormValue = reactive(_.cloneDeep(organization));

const saveDepartment = async (department: Department) => {
  const res = await createDepartment(department);
  if (res?.status === "success") {
    await fetchDepartments(
      route?.query.query ? (route?.query.query as string) : ""
    );
    router.push({
      name: "departments-id-show",
      params: { id: res?.id },
      query: { ...route.query },
    });
  } else if (res?.status === "error") {
    errors.value = res.errors;
    window.scrollTo(0, 0);
  }
};

const cancelEdit = () => {
  router.push({
    name: "departments",
    query: { ...route.query },
  });
};
</script>

<style>
ul {
  padding-left: 0 !important;
}
</style>
