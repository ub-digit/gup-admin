<template>
  <div v-if="organization" class="col-6">
    <h2>{{ organization.name }}</h2>

    <FormKit
      form-class=""
      name="form_organization"
      type="form"
      v-model="organization"
      :submit-attrs="{
        inputClass: 'btn btn-primary text-end',
      }"
      submit-label="Spara"
      @submit="saveOrg"
    >
      <FormKit
        input-class="form-control"
        label-class="form-label"
        outer-class="mb-3"
        name="name"
        label="Namn"
        type="text"
        help=""
        disabled="true"
        validation="required|length:2"
      />
      <FormKit
        input-class="form-control"
        label-class="form-label"
        outer-class="mb-3"
        name="name_sv"
        label="Namn (sv)"
        type="text"
        help=""
        validation="required|length:2"
      />
      <FormKit
        input-class="form-control"
        label-class="form-label"
        outer-class="mb-3"
        name="name_en"
        label="Namn (en)"
        type="text"
        help=""
        validation="required|length:2"
      />
      <FormKit
        input-class="form-control w-50"
        label-class="form-label"
        outer-class="mb-3"
        name="orgnr"
        label="Orgnr"
        disabled="true"
        type="text"
        help=""
        validation="length:2"
      />
      <FormKit
        input-class="form-control w-50"
        label-class="form-label"
        outer-class="mb-3"
        name="orgdbid"
        disabled="true"
        label="OrgdbID"
        type="text"
        help=""
        validation="length:2"
      />
      <FormKit
        input-class="form-control w-25"
        label-class="form-label"
        outer-class="mb-3"
        name="start_year"
        label="Startår"
        type="text"
        help=""
        validation="required"
      />
      <FormKit
        input-class="form-control w-25"
        label-class="form-label"
        outer-class="mb-3"
        name="end_year"
        label="Slutår"
        type="text"
        help=""
        validation=""
      />
    </FormKit>
    <div class="mt-3 visually-hidden">
      <div>debug</div>
      {{ organization }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useOrganizationsStore } from "~/store/organizations";
const route = useRoute();
const router = useRouter();

const organizationStore = useOrganizationsStore();

const { organization, pendingOrganization, filters } =
  storeToRefs(organizationStore);

const { fetchOrganizationById, saveOrganization } = organizationStore;
await fetchOrganizationById(route.params.id);

const saveOrg = async () => {
  const res = await saveOrganization(organization as any);
  if (res) {
    console.log("saved");
    router.push({
      name: "organizations-id-show",
      query: route.query,
      params: { id: route.params.id },
    });
  }
};
</script>

<style scoped></style>
