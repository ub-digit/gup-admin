<template>
  <div>
    <div v-if="!errorImportedPostById" class="duplicates mt-4">
      <div class="row pb-4">
        <div class="col-12">
          <h4 class="mb-1 text-muted">
            {{ t("views.publications.post.result_list_by_id.header") }}
          </h4>
          <div v-if="gupPostsById && !gupPostsById.length">
            {{
              t("views.publications.post.result_list.no_gup_posts_by_id_found")
            }}
          </div>
          <div
            v-else
            :class="{ 'opacity-50': pendingGupPostsById }"
            class="list-group list-group-flush border-bottom"
          >
            <PostRowGup
              v-for="post in gupPostsById"
              :post="post"
              :refresh="$route.query"
              :key="post.id"
            />
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-12">
          <div class="row">
            <div class="col">
              <h4 class="mb-1 text-muted">
                {{ t("views.publications.post.result_list_by_title.header") }}
              </h4>
            </div>
            <div class="col-auto">
              <Spinner v-if="pendingGupPostsByTitle" class="me-4" />
            </div>
          </div>
          <div class="row">
            <div class="col">
              <label class="d-none" for="title-search">Sök på titel</label>
              <input
                id="title-search"
                class="form-control mb-3"
                type="search"
                v-model="searchTitleStr"
              />
              <div v-if="gupPostsByTitle && !gupPostsByTitle.length">
                {{
                  t(
                    "views.publications.post.result_list.no_gup_posts_by_title_found"
                  )
                }}
              </div>
              <div
                v-else
                :class="{ 'opacity-50': pendingGupPostsByTitle }"
                class="list-group list-group-flush border-bottom"
              >
                <PostRowGup
                  v-for="post in gupPostsByTitle"
                  :post="post"
                  :key="post.id"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useDebounceFn } from "@vueuse/core";
import { useComparePostsStore } from "~/store/compare_posts";
import { useImportedPostsStore } from "~/store/imported_posts";
import { storeToRefs } from "pinia";

const { t } = useI18n();
const route = useRoute();
const searchTitleStr: Ref<string> = ref("");

const comparePostsStore = useComparePostsStore();
const importedPostsStore = useImportedPostsStore();
const { fetchGupPostsByTitle, fetchGupPostsById } = comparePostsStore;

const {
  gupPostsByTitle,
  pendingGupPostsByTitle,
  gupPostsById,
  pendingGupPostsById,
  postsCompareMatrix,
} = storeToRefs(comparePostsStore);

const { importedPostById, errorImportedPostById } =
  storeToRefs(importedPostsStore);

const debounceFn = useDebounceFn(() => {
  if (importedPostById) {
    fetchGupPostsByTitle(item_row_id, searchTitleStr.value);
  }
}, 500);

watch(searchTitleStr, () => {
  debounceFn();
});

let item_row_title: string = "";
let item_row_id: string = "";
if (
  route.params.gupid !== "empty" &&
  route.params.gupid !== "error" &&
  postsCompareMatrix &&
  postsCompareMatrix.value
) {
  item_row_title = postsCompareMatrix?.value?.find(
    (item) => item?.display_label === "title"
  )?.first.value.title;
  item_row_id = postsCompareMatrix.value.find(
    (item) => item.display_label === "id"
  )?.first.value;
} else if (
  (route.params.gupid === "empty" || route.params.gupid === "error") &&
  importedPostById.value
) {
  item_row_title = importedPostById.value.data.find(
    (item) => item.display_label === "title"
  ).first.value.title;
  item_row_id = importedPostById.value.data.find(
    (item) => item.display_label === "id"
  ).first.value;
}

onMounted(() => {
  searchTitleStr.value = item_row_title;
});

if (route.params.id) {
  await fetchGupPostsById(route.params.id as string);
}
</script>

<style lang="scss" scoped></style>
