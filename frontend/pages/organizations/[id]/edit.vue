<template>
  <div v-if="organizationFormValue" class="col-6">
    <h2>{{ organizationFormValue.name }}</h2>

    <FormKit
      name="form_organization"
      type="form"
      :config="{ validationVisibility: 'blur' }"
      v-model="organizationFormValue"
      :submit-attrs="{
        inputClass: '$reset btn btn-primary text-end',
      }"
      submit-label="Spara"
      @submit="submitHandler"
    >
      <FormKit
        outer-class="max-w-[30em]"
        name="name"
        label="Namn"
        type="text"
        help=""
        :actions="false"
        disabled="true"
        validation="required|length:2"
      />
      <FormKit
        outer-class="max-w-[30em]"
        name="name_sv"
        label="Namn (sv)"
        type="text"
        help=""
        validation="required|length:2"
      />
      <FormKit
        outer-class="max-w-[30em]"
        name="name_en"
        label="Namn (en)"
        type="text"
        help=""
        validation="required|length:2"
      />
      <FormKit
        outer-class="max-w-[15em]"
        name="orgnr"
        label="Orgnr"
        disabled="true"
        type="text"
        help=""
        validation="length:2"
      />
      <FormKit
        outer-class="max-w-[15em]"
        name="orgdbid"
        disabled="true"
        label="OrgdbID"
        type="text"
        help=""
        validation="length:2"
      />
      <FormKit
        outer-class="max-w-[10em]"
        name="start_year"
        label="Startår"
        type="text"
        help=""
        validation="required|number"
      />
      <FormKit
        outer-class="max-w-[10em]"
        name="end_year"
        label="Slutår"
        type="text"
        validation="number"
        help=""
      />
      <FormKit
        type="autocomplete"
        name="parentid"
        outer-class="max-w-[30em]"
        label="Sök efter förälder"
        placeholder="Exempel: Handelshögskolan"
        empty-message="Inga träffar"
        closeIcon="close"
        selectIcon="search"
        :options="organizationsOptionsModified"
        selection-removable
        selection-appearance="option"
        popover
      />
      <FormKit
        type="autocomplete"
        name="grandparentid"
        outer-class="max-w-[30em]"
        label="Sök efter morförälder"
        placeholder="Exempel: Handelshögskolan"
        empty-message="Inga träffar"
        closeIcon="close"
        selectIcon="search"
        :options="organizationsOptionsModified"
        selection-removable
        popover
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
import _ from "lodash";
const route = useRoute();
const router = useRouter();

const organizationStore = useOrganizationsStore();

const { organization, pendingOrganization, filters } =
  storeToRefs(organizationStore);

const { fetchOrganizationById, searchOrganizations, saveOrganization } =
  organizationStore;

await fetchOrganizationById(route.params.id as string);
const organizationsOptions = await searchOrganizations();

// deepclone object to use in form v-model
const organizationFormValue = reactive(_.cloneDeep(organization));

const organizationsOptionsModified = computed(() => {
  const data = organizationsOptions;
  return data?.map((result) => {
    return {
      label: result.name + " (" + result.id + ")",
      value: result.id,
    };
  });
});

async function organizationsSelectList({ search }: any) {
  if (!search) return [];
  const res = await searchOrganizations(search);
  if (res) {
    const data = await res;
    // Iterating over results to set the required
    // `label` and `value` keys.
    return data.map((result) => {
      return {
        label: result.name + " (" + result.id + ")",
        value: result.id,
      };
    });
  }
  // If the request fails, we return an empty array.
  return [];
}

const submitHandler = async () => {
  const res = await saveOrganization(organization as any);
  if (res) {
    router.push({
      name: "organizations-id-show",
      query: route.query,
      params: { id: route.params.id },
    });
  }
};
</script>

<style>
ul {
  padding-left: 0 !important;
}
</style>
