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
import type { Department } from "~/types/Department";
const { t, getLocale } = useI18n();

interface Props {
  department: Department;
  submitBtnText?: string;
  errors: string[];
}
const { department, submitBtnText = "Spara" } = defineProps<Props>(); // default is set for submitBtnText only
const emit = defineEmits(["submit", "onCancel"]); // handle these events in your parent component

// make a ref object to use in the form
const departmentReactive: Ref<Department> = ref(department);

function saveDepartment() {
  emit("submit", departmentReactive.value);
}
</script>

<style scoped></style>
