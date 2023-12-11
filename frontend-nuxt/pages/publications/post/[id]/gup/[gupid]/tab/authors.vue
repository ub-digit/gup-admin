<template>
  <ModalAuthor
    v-if="showModalAuthor"
    :noSuccessButton="false"
    :show="showModalAuthor"
    :sourceSelectedAuthor="selectedAuthor"
    @success="handleAuthorSelected"
    @close="showModalAuthor = false"
  />

  <div class="authors mt-4">
    <ul class="list-group list-group-flush">
      <AuthorRow
        v-for="(author, index) in authors"
        :key="index"
        :author="author"
        :index="index"
        @handleClickedPerson="handleClickedPerson(author, index)"
        @handleMoveDown="handleMoveDown(author, index)"
        @handleMoveUp="handleMoveUp(author, index)"
      />
    </ul>
  </div>
</template>

<script setup>
import { useComparePostsStore } from "~/store/compare_posts";
import { useImportedPostsStore } from "~/store/imported_posts";
import { storeToRefs } from "pinia";

let showModalAuthor = ref(false);
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
  showModalAuthor.value = true;
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
    isMatch: index % 2 ? true : false,
    x_account: "xavgo_" + index,
    full_name: author.name,
    departments: [{ id: 1, name: "bar_foo_" + index }],
  };
});

function handleAuthorSelected(author) {
  if (author) {
    selectedAuthor.value = author;
    authors.value[selectedAuthorIndex.value] = author;
    selectedAuthorIndex.value = null;
    selectedAuthorIndex.value = null;
  }
  showModalAuthor.value = false;
}

function handleMoveUp(author, index) {
  if (index > 0) {
    const temp = authors.value[index - 1];
    authors.value[index - 1] = author;
    authors.value[index] = temp;
  }
}

function handleMoveDown(author, index) {
  if (index < authors.value.length - 1) {
    const temp = authors.value[index + 1];
    authors.value[index + 1] = author;
    authors.value[index] = temp;
  }
}

function handleSuccess() {
  console.log("handleSuccess");
  showModalAuthor.value = false;
}
</script>

<style lang="scss" scoped></style>
