<template>
  <div v-if="department" class="row">
    <div class="col">
      <h2>Redigera institution</h2>

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
import type { Department } from "~/types/Author";
const route = useRoute();
const router = useRouter();

const departmentStore = useDepartmentStore();

const { department } = storeToRefs(departmentStore);
const { fetchDepartment, updateDepartment } = departmentStore;
const errors: Ref<string[]> = ref([]);

await fetchDepartment(route?.params?.id as string);

// deepclone object to use in form v-model
//const organizationFormValue = reactive(_.cloneDeep(organization));

const saveDepartment = async (department: Department) => {
  const res = await updateDepartment(route.params.id as string, department);
  if (res?.status === "success") {
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
    name: "departments-id-show",
    params: { id: route.params.id },
    query: { ...route.query },
  });
};
</script>

<style>
ul {
  padding-left: 0 !important;
}
</style>
