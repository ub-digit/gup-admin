<template>
  <div>
    <div v-if="errors?.length" class="alert alert-danger">
      <ul>
        <li v-for="error in errors" :key="error">
          {{ t(`views.departments.edit.form.errors.${error}`) }}
        </li>
      </ul>
    </div>
    <form v-if="departmentReactive">
      <div class="row">
        <div class="col-6">
          <div class="col-12 mb-3">
            <label for="name" class="form-label"
              >Namn (svenska) <span style="color: red">*</span></label
            >
            <input
              type="text"
              class="form-control"
              v-model="departmentReactive.name_sv"
            />
          </div>
          <div class="col-12 mb-3">
            <label for="name" class="form-label"
              >Namn (engelska) <span style="color: red">*</span></label
            >
            <input
              type="text"
              class="form-control"
              v-model="departmentReactive.name_en"
            />
          </div>
          <div class="col-12 mb-3">
            <div class="form-check">
              <input
                class="form-check-input"
                type="checkbox"
                v-model="departmentReactive.is_faculty"
                id="isFaculty"
              />
              <label class="form-check-label" for="isFaculty">
                Faktultet
              </label>
            </div>
            <div class="form-check">
              <input
                class="form-check-input"
                type="checkbox"
                v-model="departmentReactive.is_internal"
                id="isInternal"
              />
              <label class="form-check-label" for="isInternal"> Intern </label>
            </div>
          </div>
          <div class="col-12 mb-3" v-if="!departmentReactive.is_faculty">
            <label for="parentID" class="form-label">Välj förälder</label>
            <Multiselect
              id="parentID"
              v-model="selectedDepartment"
              :options="departments"
              :internal-search="false"
              placeholder="Välj förälder"
              track-by="id"
              label="name_sv"
              :searchable="true"
              @search-change="fetchDepartments"
              :loading="isLoadingDepartments"
              optionsLimit="2"
            ></Multiselect>
          </div>
          <div class="col-12 mb-3">
            <div class="row">
              <div class="col">
                <label for="start_year" class="form-label"
                  >Startår <span style="color: red">*</span></label
                >
                <input
                  name="start_year"
                  type="number"
                  class="form-control"
                  v-model="departmentReactive.start_year"
                />
              </div>
              <div class="col">
                <label for="end_year" class="form-label">Slutår</label>
                <input
                  type="number"
                  class="form-control"
                  v-model="departmentReactive.end_year"
                />
              </div>
            </div>
          </div>
          <div class="col-12 mb-3">
            <label for="orgnr" class="form-label">Orgnr</label>
            <input
              name="orgnr"
              type="text"
              class="form-control"
              v-model="departmentReactive.orgnr"
            />
          </div>
          <div class="col-12 mb-3">
            <label for="Orgdbid" class="form-label">Orgdbid</label>
            <input
              name="Orgdbid"
              type="text"
              class="form-control"
              v-model="departmentReactive.orgdbid"
            />
          </div>
        </div>
      </div>

      <button class="btn btn-danger me-2" @click.prevent="$emit('onCancel')">
        Avbryt
      </button>
      <button
        type="button"
        class="btn btn-success"
        @click.prevent="saveDepartment()"
      >
        {{ submitBtnText }}
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { Value } from "sass";
import multiselect from "~/plugins/multiselect";
import type { Department } from "~/types/Department";
const { t, getLocale } = useI18n();

interface Props {
  department: Department;
  submitBtnText?: string;
  errors: string[];
}

const selectedDepartment = ref(null);

const isLoadingDepartments = ref(false);

const departments: Ref<Department[]> = ref([]);

const fetchDepartments = async (query: string) => {
  isLoadingDepartments.value = true;
  const { data, error } = await useFetch("/api/departments/suggest/", {
    params: { query },
  });
  if (error.value) {
    console.error("Error fetching departments:", error.value);
  }
  departments.value = data?.value?.data as Department[];
  isLoadingDepartments.value = false;
};
const { department, submitBtnText = "Spara" } = defineProps<Props>(); // default is set for submitBtnText only
const emit = defineEmits(["submit", "onCancel"]); // handle these events in your parent component

// make a ref object to use in the form
const departmentReactive: Ref<Department> = ref(department);

function saveDepartment() {
  if (departmentReactive.value.is_faculty) {
    departmentReactive.value.parentid = null;
  } else {
    departmentReactive.value.parentid = selectedDepartment.value?.id
      ? selectedDepartment.value.id
      : null;
  }
  emit("submit", departmentReactive.value);
}
</script>

<style scoped></style>
