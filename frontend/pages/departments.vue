<template>
  <div>
    <Head>
      <title>{{ t("seo.application_title") }} - institution</title>
      <Meta name="description" :content="t('seo.application_title')" />
    </Head>
    <div class="container-fluid">
      <div class="row">
        <div class="col-4 me-2">
          <div class="row">
            <div class="col">
              <label for="search" class="form-label">Sök</label>
              <input
                type="search"
                id="search"
                class="form-control"
                placeholder="Sök"
                v-model="searchStr"
              />
            </div>
          </div>
          <div class="row">
            <div class="col opacity-50 text-center mb-4">
              <strong>
                {{ numberOfDepartmentsShowing }}
                {{ t("views.publications.result_list.meta.of") }}
                {{ numberOfDepartmentsTotal }}
                {{ t("views.publications.result_list.meta.posts") }}</strong
              >
            </div>
          </div>
          <div id="result-list-by-id" class="row">
            <div
              class="col scroll"
              :class="{ 'opacity-50': pendingDepartments }"
            >
              <div v-if="departments && !departments.length">
                {{
                  t("views.publications.result_list.no_imported_posts_found")
                }}
              </div>
              <div v-else class="list-group list-group-flush border-bottom">
                <PostRowDepartment
                  v-for="post in departments"
                  :post="post"
                  :key="post.id"
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
</template>

<script lang="ts" setup>
import { useDepartmentStore } from "~/store/departments";
import { storeToRefs } from "pinia";
import _ from "lodash";

const searchStr = ref();
const { t, getLocale } = useI18n();
const config = useRuntimeConfig();
const route = useRoute();
const router = useRouter();

const departmentStore = useDepartmentStore();
const { fetchDepartments } = departmentStore;

// throttle input
const debouncedFn = useDebounceFn(() => {
  fetchDepartments(searchStr.value);
}, 500);

watch(searchStr, () => {
  debouncedFn();
});

const {
  departments,
  numberOfDepartmentsTotal,
  numberOfDepartmentsShowing,
  pendingDepartments,
  filter,
} = storeToRefs(departmentStore);

searchStr.value = filter.value.query || "";
await fetchDepartments(searchStr.value);
</script>

<style lang="scss">
.scroll {
  max-height: 100vh;
  overflow-y: scroll;
}
</style>
