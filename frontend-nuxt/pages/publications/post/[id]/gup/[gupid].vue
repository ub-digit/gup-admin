<template>
  <div>
    <div class="row">
      <!-- use the modal component, pass in the prop -->
      <modal
        :show="showModal"
        @success="handleSuccess"
        @close="showModal = false"
      >
        <template #header>
          <h4>{{ t("messages.create_in_gup_success") }}</h4>
        </template>
        <template #body>
          <p>{{ t("messages.create_in_gup_success_body") }}</p>
        </template>
      </modal>

      <modal
        :show="showModalMerge"
        @success="handleSuccessMerge"
        @close="showModalMerge = false"
      >
        <template #header>
          <h4>{{ t("messages.merge_in_gup_success") }}</h4>
        </template>
        <template #body>
          <p>{{ t("messages.merge_in_gup_success_body") }}</p>
          <p><strong>Titel:</strong> {{ item_row_title }}</p>
          <p><strong>ID:</strong> {{ item_row_id }}</p>
        </template>
      </modal>

      <div
        v-if="route.params.gupid !== 'empty' && route.params.gupid !== 'error'"
      >
        <Spinner v-if="pendingCompareGupPostWithImported" class="me-4" />
        <PostDisplayCompare
          v-if="gupCompareImportedMatrix"
          :dataMatrix="gupCompareImportedMatrix.data"
        />
      </div>
      <div v-else class="row">
        <div class="col-6">
          <ErrorLoadingPost
            v-if="errorImportedPostById"
            :error="errorImportedPostById"
          />
          <div v-if="!errorImportedPostById">
            <span v-if="isPendingUpdate">Fetching updated post from gup..</span
            ><Spinner
              v-if="isPendingUpdate || pendingImportedPostById"
              class="me-4"
            />
            <PostDisplayCompare
              v-if="!isPendingUpdate"
              :dataMatrix="importedPostById && importedPostById.data"
            />
          </div>
        </div>
        <div class="col-6">
          <ErrorLoadingPost
            v-if="route.params.gupid === 'error'"
            :error="{ statusMessage: 'Error loading post' }"
          />
          <NothingSelected v-if="route.params.gupid === 'empty'" />
        </div>
      </div>
    </div>
    <div v-if="!errorImportedPostById" class="action-bar">
      <div class="row pb-4 mt-4">
        <div class="col-6 text-end">
          <button type="button" class="btn btn-danger me-1" @click="removePost">
            {{ t("buttons.remove") }}
          </button>
          <button
            type="button"
            class="btn btn-secondary me-1"
            @click="editPost"
          >
            {{ t("buttons.edit") }}
          </button>
          <button
            :disabled="!gupCompareImportedMatrix"
            type="button"
            class="btn btn-success"
            @click="merge"
          >
            {{ t("buttons.merge") }}
          </button>
        </div>
      </div>
    </div>
    <div v-if="!errorImportedPostById" class="duplicates">
      <div class="row">
        <div class="col-6">
          <h3 class="mb-4">
            {{ t("views.publications.post.result_list.header") }}
          </h3>
        </div>
      </div>

      <div class="row pb-4">
        <div class="col-6">
          <h4 class="mb-1 text-muted">
            {{ t("views.publications.post.result_list_by_id.header") }}
          </h4>
          <div v-if="gupPostsById.data && !gupPostsById.data.length">
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
              v-for="post in gupPostsById.data"
              :post="post"
              :refresh="$route.query"
              :key="post.id"
            />
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-6">
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
              <div v-if="gupPostsByTitle.data && !gupPostsByTitle.data.length">
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
                  v-for="post in gupPostsByTitle.data"
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

<script setup>
import { useDebounceFn } from "@vueuse/core";
import { useGupPostsStore } from "~/store/gup_posts";
import { useImportedPostsStore } from "~/store/imported_posts";
import { useFilterStore } from "~~/store/filter";
import { storeToRefs } from "pinia";

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const searchTitleStr = ref(null);
const { $toast } = useNuxtApp();
const config = useRuntimeConfig();
const showModal = ref(false);
const showModalMerge = ref(false);
const isPendingUpdate = ref(false);

const filterStore = useFilterStore();
const importedPostsStore = useImportedPostsStore();
const {
  fetchImportedPostById,
  removeImportedPost,
  fetchImportedPosts,
  createImportedPostInGup,
  mergePosts,
  $importedReset,
} = importedPostsStore;
const {
  importedPostById,
  pendingImportedPostById,
  pendingCreateImportedPostInGup,
  errorImportedPostById,
  selectedUser,
} = storeToRefs(importedPostsStore);
const gupPostsStore = useGupPostsStore();
const {
  fetchGupPostsByTitle,
  fetchGupPostsById,
  fetchCompareGupPostWithImported,
} = gupPostsStore;
const {
  gupPostsByTitle,
  pendingGupPostsByTitle,
  gupPostsById,
  pendingGupPostsById,
  gupPostById,
  gupCompareImportedMatrix,
  errorGupCompareImportedMatrix,
  pendingCompareGupPostWithImported,
  pendingGupPostById,
  errorGupPostById,
} = storeToRefs(gupPostsStore);

if (route.params.gupid === "empty" || route.params.gupid === "error") {
  await fetchImportedPostById(route.params.id);
  if (!errorImportedPostById.value) {
    if (importedPostById.value.pending) {
      await pollForUpdate();
    }
    gupPostsStore.$reset();
  }
} else {
  await fetchCompareGupPostWithImported(route.params.id, route.params.gupid);
  if (
    errorGupCompareImportedMatrix &&
    errorGupCompareImportedMatrix.value &&
    errorGupCompareImportedMatrix.value.error.code
  ) {
    console.log(errorGupCompareImportedMatrix.value.error);
    if (errorGupCompareImportedMatrix.value.error.code === "404") {
      router.push({
        path: `/publications/post/${route.params.id}/gup/empty`,
        query: { ...route.query },
      });
    } else if (errorGupCompareImportedMatrix.value.error.code === "200") {
      router.push({
        path: `/publications/post/${route.params.id}/gup/error`,
        query: { ...route.query },
      });
      gupPostsStore.$reset();
    }
  }
}

// because of the array structure in data make sure to pick up the properties needed
let item_row_title = null;
let item_row_id = null;
let item_row_source = null;
let item_row_publication_id = null;
if (
  route.params.gupid !== "empty" &&
  route.params.gupid !== "error" &&
  gupCompareImportedMatrix.value &&
  gupCompareImportedMatrix.value.data
) {
  item_row_publication_id = gupCompareImportedMatrix.value.data.find(
    (item) => item.display_label === "publication_id"
  ).first.value;
  item_row_id = gupCompareImportedMatrix.value.data.find(
    (item) => item.display_label === "id"
  ).first.value;
  item_row_source = gupCompareImportedMatrix.value.data.find(
    (item) => item.display_type === "meta"
  ).first.value.source.value;
  item_row_title = gupCompareImportedMatrix.value.data.find(
    (item) => item.display_label === "title"
  ).first.value.title;
} else if (route.params.gupid === "empty" && importedPostById.value) {
  item_row_publication_id = importedPostById.value.data.find(
    (item) => item.display_label === "publication_id"
  ).first.value;
  item_row_id = importedPostById.value.data.find(
    (item) => item.display_label === "id"
  ).first.value;
  item_row_source = importedPostById.value.data.find(
    (item) => item.display_type === "meta"
  ).first.value.source.value;
  item_row_title = importedPostById.value.data.find(
    (item) => item.display_label === "title"
  ).first.value.title;
}

const debounceFn = useDebounceFn(() => {
  if (importedPostById) {
    fetchGupPostsByTitle(item_row_id, searchTitleStr.value);
  }
}, 500);

watch(searchTitleStr, () => {
  debounceFn();
});

async function merge() {
  if (selectedUser.value !== "") {
    const ok = confirm(t("messages.confirm_merge_in_gup"));
    if (ok) {
      const res = await mergePosts(
        route.params.id,
        route.params.gupid,
        selectedUser.value
      );
      if (res) {
        showModalMerge.value = true;
      } else if (res.error) {
        $toast.error(t("messages.merge_in_gup_error"));
      }
    }
  } else {
    alert("No user selected");
  }
}
async function removePost() {
  const ok = confirm(t("messages.confirm_remove"));
  if (ok) {
    const response = await removeImportedPost(item_row_id);
    console.log(response);
    if (!response.error) {
      fetchImportedPosts();
      $toast.success(t("messages.remove_success"));
      router.push({ path: "/publications", query: { ...route.query } });
    } else {
      $toast.error(
        t("messages.remove_error") + "<p>" + response.error.statusMessage
      );
    }
  }
}

async function pollForUpdate() {
  isPendingUpdate.value = true;
  await fetchImportedPostById(route.params.id);
  if (!importedPostById.value.pending) {
    isPendingUpdate.value = false;
    return;
  }
  setTimeout(() => {
    pollForUpdate();
  }, 500);
}

async function handleSuccess() {
  const response = await removeImportedPost(item_row_id);
  fetchImportedPosts();
  showModal.value = false;
  $toast.success(t("messages.remove_success"));
  router.push({ path: "/publications", query: { ...route.query } });
}

async function handleSuccessMerge() {
  const response = await removeImportedPost(item_row_id);
  fetchImportedPosts();
  showModalMerge.value = false;
  $toast.success(t("messages.remove_success"));
  router.push({
    path: `/publications/post/${route.params.gupid}/gup/empty`,
    query: { ...route.query },
  });
}

async function editPost() {
  if (selectedUser.value !== "") {
    let ok = null;
    if (item_row_source === "gup") {
      ok = confirm(t("messages.confirm_open_in_gup"));
    } else {
      ok = confirm(t("messages.confirm_create_in_gup"));
    }
    if (ok) {
      if (item_row_source !== "gup") {
        const response = await createImportedPostInGup(
          item_row_id,
          selectedUser.value
        );
        if (!response.error) {
          const url = response.link; //config.public.API_GUP_BASE_URL_EDIT + response.id;
          window.open(url, "_blank");
          showModal.value = true;
        } else if (response.error) {
          $toast.error(t("messages.create_in_gup_error"));
        }
      } else if (item_row_source === "gup") {
        window.open(
          `${config.public.API_GUP_BASE_URL_EDIT}${item_row_publication_id}`,
          "_blank"
        );
      }
    }
  } else {
    alert("No user selected!");
  }
}

onMounted(() => {
  searchTitleStr.value = item_row_title;
});

if (!errorImportedPostById) {
  await fetchGupPostsById(route.params.id);
}
</script>

<style lang="scss" scoped>
.col {
}
</style>
