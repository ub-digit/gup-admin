<template>
  <modal
    :noSuccessButton="true"
    :show="showModalPerson"
    @success="handleSuccess"
    @close="showModalPerson = false"
  >
    <template #header>
      <h4>Hantera person</h4>
    </template>
    <template #body>
      <PersonSearch
        :person="selectedAuthor"
        @authorSelected="handleAuthorSelected"
      />
    </template>
  </modal>

  <div class="authors mt-4">
    <ul class="list-group list-group-flush">
      <li
        class="list-group-item"
        v-for="(author, index) in authors"
        :key="index"
      >
        <div>
          <a href="#" @click.prevent="handleClickedPerson(author, index)">
            {{ author.full_name }}
          </a>
        </div>
        <div class="small">{{ author.department }}</div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { useComparePostsStore } from "~/store/compare_posts";
import { useImportedPostsStore } from "~/store/imported_posts";
import { storeToRefs } from "pinia";

let showModalPerson = ref(false);
let selectedAuthor = ref(null);
let selectedAuthorIndex = ref(null);

const route = useRoute();

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

const handleClickedPerson = (author, index) => {
  selectedAuthor.value = author;
  selectedAuthorIndex.value = index;
  showModalPerson.value = true;
};

const authors = ref([]);

if (route.params.gupid !== "empty" && route.params.gupid !== "error") {
  authors.value = postsCompareMatrix?.value?.data?.find(
    (item) => item.display_type === "authors"
  ).first.value;
} else {
  authors.value = importedPostById?.value?.data?.find(
    (item) => item.display_type === "authors"
  ).first.value;
}

authors.value = authors.value.map((author, index) => {
  return {
    id: index,
    x_account: "xavgo_" + index,
    full_name: author.name,
    department: "bar_foo_" + index,
  };
});

function handleAuthorSelected(author) {
  selectedAuthor.value = author;
  authors.value[selectedAuthorIndex.value] = author;
  selectedAuthorIndex.value = null;
  selectedAuthorIndex.value = null;
  showModalPerson.value = false;
}

function handleSuccess() {
  showModalPerson.value = false;
}
</script>

<style lang="scss" scoped></style>
