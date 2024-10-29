<template>
  <div>
    <Head>
      <title>{{ t("seo.application_title") }} - organisationer</title>
      <Meta name="description" :content="t('seo.application_title')" />
    </Head>
    <div>
      <div class="container-fluid">
        <div class="row">
          <div class="col-4 me-2">
            <div class="row">
              <div class="col" style="min-height: 15px">
                <Spinner v-if="pendingOrganizations" class="me-4" />
              </div>
            </div>
            <div class="row">
              <form class="col mb-3" @submit.prevent="void 0" id="filters">
                <label for="search_name" class="form-label"
                  >Sök organisation</label
                >
                <input
                  ref="input_search_name"
                  name="search_name"
                  id="search_name"
                  type="search"
                  v-model="filters.query"
                  class="form-control"
                  aria-placeholder="Sök organisationer"
                  placeholder="sök organisationer"
                />
              </form>
            </div>
            <div class="row">
              <div class="col opacity-50 text-center mb-4">
                <strong>
                  {{ organizationsMeta.showing }}
                  {{ t("views.publications.result_list.meta.of") }}
                  {{ organizationsMeta.total }}
                  {{ t("views.publications.result_list.meta.posts") }}</strong
                >
              </div>
            </div>
            <div id="result-list" class="row">
              <div
                class="col scroll"
                :class="{ 'opacity-50': pendingOrganizations }"
              >
                <div v-if="!organizations?.length">
                  Hittade inga organisationer
                </div>
                <div v-else class="list-group list-group-flush border-bottom">
                  <OrganizationListRow
                    v-for="org in organizations"
                    :organization="org"
                    :key="org.id"
                  />
                </div>
              </div>
            </div>
          </div>
          <div class="col">
            <div class="row">
              <NuxtPage />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useOrganizationsStore } from "../store/organizations";
const input_search_name = ref<HTMLInputElement | null>(null);
const { t, getLocale } = useI18n();
const storeOrganization = useOrganizationsStore();
const { fetchOrganizations } = storeOrganization;
await fetchOrganizations();
const { organizations, organizationsMeta, pendingOrganizations, filters } =
  storeToRefs(storeOrganization);

watchEffect(() => {
  if (input_search_name.value) {
    input_search_name.value.focus();
  }
});
</script>

<style lang="scss" scoped></style>
