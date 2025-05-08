<template>
  <div class="row">
    <div class="col d-flex justify-content-end">
      <NuxtLink
        class="btn btn-link"
        :to="{
          name: 'departments-id-edit',
          query: $route.query,
          params: { id: department?.id },
        }"
      >
        Redigera
      </NuxtLink>
    </div>
  </div>

  <div class="row" v-if="department">
    <div class="col-12" style="max-width: 800px">
      <div class="row">
        <h1>{{ department.name_sv }}</h1>
      </div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Skapad:</strong>
      </div>
      <div class="col">{{ department.created_at }}</div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Uppdaterad:</strong>
      </div>
      <div class="col">{{ department.updated_at }}</div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Namn (sv):</strong>
      </div>
      <div class="col">{{ department.name_sv }}</div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Namn (en):</strong>
      </div>
      <div class="col">{{ department.name_en }}</div>
    </div>

    <div class="row mb-3">
      <div class="col-3">
        <strong>Orgnr:</strong>
      </div>
      <div class="col">
        {{ department.orgnr ? department.orgnr : "missing" }}
      </div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Orgdbid:</strong>
      </div>
      <div class="col">
        {{ department.orgdbid ? department.orgdbid : "missing" }}
      </div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Startår:</strong>
      </div>
      <div class="col">
        {{ department.start_year ? department.start_year : "missing" }}
      </div>
    </div>
    <div class="row mb-3">
      <div class="col-3">
        <strong>Slutår:</strong>
      </div>
      <div class="col">
        {{ department.end_year ? department.end_year : "missing" }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useDepartmentStore } from "~/store/departments";
const route = useRoute();

const departmentStore = useDepartmentStore();
const { department } = storeToRefs(departmentStore);

const { fetchDepartment } = departmentStore;
await fetchDepartment(route.params.id as string);
</script>

<style scoped></style>
