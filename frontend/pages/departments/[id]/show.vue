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

  <div class="col-6" v-if="department">
    <div class="row">
      <div class="col-6">
        <h2>{{ department.name }}</h2>
      </div>
    </div>
    <table class="table">
      <tbody>
        <tr>
          <th>Id</th>
          <td>{{ department.id }}</td>
        </tr>
        <tr>
          <th>Namn</th>
          <td>{{ department.name }}</td>
        </tr>
        <tr>
          <th>Namn (sv)</th>
          <td>{{ department.name_sv }}</td>
        </tr>
        <tr></tr>
        <tr>
          <th>Namn (en)</th>
          <td>{{ department.name_en }}</td>
        </tr>
        <tr></tr>
        <tr>
          <th>Orgnr</th>
          <td>
            {{ department.orgnr ? department.orgnr : "missing" }}
          </td>
        </tr>
        <tr>
          <th>OrgdbID</th>
          <td>
            {{ department.orgdbid ? department.orgdbid : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Startår</th>
          <td>
            {{ department.start_year ? department.start_year : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Slutår</th>
          <td>
            {{ department.end_year ? department.end_year : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Förälder</th>
          <td>
            <span v-if="department.parentid">
              <NuxtLink
                target="_blank"
                :to="{
                  name: 'departments-id-show',
                  query: $route.query,
                  params: { id: department.parentid },
                }"
              >
                {{ department.parentid ? department.parentid : "" }}
              </NuxtLink>
              <font-awesome-icon
                class="ms-2"
                icon="fa-solid fa-external-link"
              />
            </span>
            <span v-else>missing</span>
          </td>
        </tr>
        <tr>
          <th>Morförälder</th>
          <td>
            <span v-if="department.grandparentid">
              <NuxtLink
                v-if="department.grandparentid"
                :to="{
                  name: 'departments-id-show',
                  query: $route.query,
                  params: { id: department.grandparentid },
                }"
              >
                {{ department.grandparentid ? department.grandparentid : "" }}
              </NuxtLink>
              <font-awesome-icon
                class="ms-2"
                icon="fa-solid fa-external-link"
              />
            </span>
            <span v-else>missing</span>
          </td>
        </tr>
        <tr>
          <th>Created at</th>
          <td>{{ department.created_at }}</td>
        </tr>
        <tr>
          <th>Updated at</th>
          <td>{{ department.updated_at }}</td>
        </tr>
        <tr>
          <th>Created by</th>
          <td>
            {{ department.created_by ? department.created_by : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Updated by</th>
          <td>
            {{ department.updated_by ? department.updated_by : "missing" }}
          </td>
        </tr>
      </tbody>
    </table>

    <div class="visually-hidden">
      <h3>debug</h3>
      {{ department }}
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
