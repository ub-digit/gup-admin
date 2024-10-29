<template>
  <div>
    <h2>{{ organization.name }}</h2>

    <table class="table">
      <tbody>
        <tr>
          <th>Id</th>
          <td>{{ organization.id }}</td>
        </tr>
        <tr>
          <th>Namn</th>
          <td>{{ organization.name }}</td>
        </tr>
        <tr>
          <th>Namn (sv)</th>
          <td>{{ organization.name_sv }}</td>
        </tr>
        <tr></tr>
        <tr>
          <th>Namn (en)</th>
          <td>{{ organization.name_en }}</td>
        </tr>
        <tr></tr>
        <tr>
          <th>Orgnr</th>
          <td>
            {{ organization.orgnr ? organization.orgnr : "missing" }}
          </td>
        </tr>
        <tr>
          <th>OrgdbID</th>
          <td>
            {{ organization.orgdbid ? organization.orgdbid : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Startår</th>
          <td>
            {{ organization.start_year ? organization.start_year : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Slutår</th>
          <td>
            {{ organization.end_year ? organization.end_year : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Förälder</th>
          <td>
            <span v-if="organization.parentid">
              <NuxtLink
                target="_blank"
                :to="{
                  name: 'organizations-id',
                  query: $route.query,
                  params: { id: organization.parentid },
                }"
              >
                {{ organization.parentid ? organization.parentid : "" }}
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
            <span v-if="organization.grandparentid">
              <NuxtLink
                v-if="organization.grandparentid"
                :to="{
                  name: 'organizations-id',
                  query: $route.query,
                  params: { id: organization.grandparentid },
                }"
              >
                {{
                  organization.grandparentid ? organization.grandparentid : ""
                }}
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
          <td>{{ organization.created_at }}</td>
        </tr>
        <tr>
          <th>Updated at</th>
          <td>{{ organization.updated_at }}</td>
        </tr>
        <tr>
          <th>Created by</th>
          <td>
            {{ organization.created_by ? organization.created_by : "missing" }}
          </td>
        </tr>
        <tr>
          <th>Updated by</th>
          <td>
            {{ organization.updated_by ? organization.updated_by : "missing" }}
          </td>
        </tr>
      </tbody>
    </table>

    <div class="visually-hidden">
      <h3>debug</h3>
      {{ organization }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useOrganizationsStore } from "../store/organizations";
const route = useRoute();

const organizationStore = useOrganizationsStore();

const { organization, pendingOrganization, filters } =
  storeToRefs(organizationStore);

const { fetchOrganizationById } = organizationStore;
await fetchOrganizationById(route.params.id);
</script>

<style scoped></style>
