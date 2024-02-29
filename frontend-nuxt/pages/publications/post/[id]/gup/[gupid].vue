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

      <div v-if="showCompareView">
        <Spinner v-if="pendingComparePost" class="me-4" />
        <PostDisplayCompare
          v-if="postsCompareMatrix"
          :dataMatrix="postsCompareMatrix"
        />
      </div>
      <div v-else class="row">
        <div class="col-6">
          <ErrorLoadingPost
            v-if="errorImportedPostById"
            :error="errorImportedPostById.error"
          />
          <div v-else>
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
            :error="{ message: 'Error loading post' }"
          />
          <NothingSelected v-if="route.params.gupid === 'empty'" />
        </div>
      </div>
    </div>
    <div
      v-if="
        !errorImportedPostById &&
        (postsCompareMatrix || importedPostById) &&
        !isPendingUpdate
      "
      class="action-bar"
    >
      <div class="row pb-4 mt-4">
        <div class="col-6 text-end">
          <button
            :disabled="isRemoveDisabled"
            type="button"
            class="btn btn-danger me-1"
            @click="removePost"
          >
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
            :disabled="!postsCompareMatrix"
            type="button"
            class="btn btn-success"
            @click="merge"
          >
            {{ t("buttons.merge") }}
          </button>
        </div>
      </div>
    </div>

    <div class="row">
      <nav class="col-6">
        <ul v-if="!isPendingUpdate" class="nav nav-tabs">
          <li class="nav-item">
            <NuxtLink
              :to="{
                name: 'publications-post-id-gup-gupid-tab',
                query: $route.query,
                params: {
                  id: route.params.id,
                  gupid: route.params.gupid,
                },
              }"
              class="nav-link"
              >Dubletter</NuxtLink
            >
          </li>
          <li class="nav-item">
            <NuxtLink
              :to="{
                name: 'publications-post-id-gup-gupid-tab-authors',
                query: $route.query,
                params: {
                  id: route.params.id,
                  gupid: route.params.gupid,
                },
              }"
              class="nav-link"
              >Personer</NuxtLink
            >
          </li>
        </ul>
        <!-- this is outlet for tab content -->
        <NuxtPage v-if="!isPendingUpdate" />
      </nav>
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
const router = useRouter();
//const searchTitleStr = ref("");
const { $toast } = useNuxtApp();
const config = useRuntimeConfig();
const showModal = ref(false);
const showModalMerge = ref(false);
const isPendingUpdate = ref(false);
let done = false;

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
const comparePostsStore = useComparePostsStore();
const { fetchGupPostsByTitle, fetchGupPostsById, fetchComparePostsMatrix } =
  comparePostsStore;
const {
  gupPostsByTitle,
  pendingGupPostsByTitle,
  gupPostsById,
  pendingGupPostsById,
  postsCompareMatrix,
  errorPostsCompareMatrix,
  pendingComparePost,
} = storeToRefs(comparePostsStore);

if (route.params.gupid === "empty" || route.params.gupid === "error") {
  await fetchImportedPostById(route.params.id as string);
  if (!errorImportedPostById.value) {
    if (importedPostById?.value?.pending) {
      await pollForUpdate();
    }
    comparePostsStore.$reset();
  }
} else {
  await fetchComparePostsMatrix(
    route.params.id as string,
    route.params.gupid as string
  );
  if (
    errorPostsCompareMatrix &&
    errorPostsCompareMatrix.value &&
    errorPostsCompareMatrix.value.code
  ) {
    if (errorPostsCompareMatrix.value.code === "666") {
      router.push({
        path: `/publications/post/${route.params.id}/gup/error/tab`,
        query: { ...route.query },
      });
    } else if (errorPostsCompareMatrix.value.code === "404") {
      router.push({
        path: `/publications/post/${route.params.id}/gup/empty/tab`,
        query: { ...route.query },
      });
    } else if (errorPostsCompareMatrix.value.code === "200") {
      router.push({
        path: `/publications/post/${route.params.id}/gup/error/tab`,
        query: { ...route.query },
      });
      comparePostsStore.$reset();
    }
  }
}

// because of the array structure in data make sure to pick up the properties needed
let item_row_title: string | null = null;
let item_row_id: string = "";
let item_row_source: string | null = null;
let item_row_publication_id: string | null = null;
if (
  route.params.gupid !== "empty" &&
  route.params.gupid !== "error" &&
  postsCompareMatrix.value
) {
  item_row_publication_id = postsCompareMatrix.value.find(
    (item) => item.display_label === "publication_id"
  )?.first.value;
  item_row_id = postsCompareMatrix.value.find(
    (item) => item.display_label === "id"
  )?.first.value;
  item_row_source = postsCompareMatrix.value.find(
    (item) => item.display_type === "meta"
  )?.first.value.source.value;
  item_row_title = postsCompareMatrix.value.find(
    (item) => item.display_label === "title"
  )?.first.value.title;
} else if (
  (route.params.gupid === "empty" || route.params.gupid === "error") &&
  importedPostById.value &&
  importedPostById.value.data
) {
  item_row_publication_id = importedPostById.value.data.find(
    (item) => item.display_label === "publication_id"
  )?.first.value;
  item_row_id = importedPostById.value.data.find(
    (item) => item.display_label === "id"
  )?.first.value;
  item_row_source = importedPostById.value.data.find(
    (item) => item.display_type === "meta"
  )?.first.value.source.value;
  item_row_title = importedPostById.value.data.find(
    (item) => item.display_label === "title"
  )?.first.value.title;
}

async function merge() {
  if (selectedUser.value !== "") {
    const ok = confirm(t("messages.confirm_merge_in_gup"));
    if (ok) {
      const res = await mergePosts(
        route.params.id as string,
        route.params.gupid as string,
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
  if (done) return;
  isPendingUpdate.value = true;
  await fetchImportedPostById(route.params.id as string);
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
  showModalMerge.value = false;
  const response = await removeImportedPost(item_row_id);
  fetchImportedPosts();
  $toast.success(t("messages.remove_success"));
  router.push({
    path: `/publications/post/${route.params.gupid}/gup/empty/tab/`,
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

onUnmounted(() => {
  done = true;
});

const isRemoveDisabled = computed(() => {
  if (item_row_source === "gup") {
    return true;
  }
});

const showCompareView = computed(() => {
  if (route.params.gupid !== "empty" && route.params.gupid !== "error") {
    return true;
  }
});
</script>

<style lang="scss" scoped>
.nav-item {
  .nav-link {
    &.router-link-active {
      color: #495057;
      background-color: #fff;
      border-color: #dee2e6 #dee2e6 #fff;
    }
  }
}

.col {
}
</style>
