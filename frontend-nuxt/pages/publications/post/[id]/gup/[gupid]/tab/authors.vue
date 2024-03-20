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
        v-for="(author, index) in authorsByPublication"
        :key="index"
        :author="author"
        :index="index"
        @handleRemovePerson="handleRemovePerson(author, index)"
        @handleClickedPerson="handleClickedPerson(author, index)"
        @handleMoveDown="handleMoveDown(author, index)"
        @handleMoveUp="handleMoveUp(author, index)"
      />
    </ul>
  </div>
</template>

<script setup lang="ts">
import { useComparePostsStore } from "~/store/compare_posts";
import { useImportedPostsStore } from "~/store/imported_posts";
import { useAuthorsStore } from "~/store/authors";
import { storeToRefs } from "pinia";
import type { Author } from "~/types/Author";
import { ref } from "vue";
import type { Ref } from "vue";

let showModalAuthor = ref(false);
let selectedAuthor: Ref<Author | null> = ref(null);
let selectedAuthorIndex: Ref<number | null> = ref(null);

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

const { importedPostById } = storeToRefs(importedPostsStore);

const authorsStore = useAuthorsStore();
const { fetchAuthorsByPublication } = authorsStore;
const { authorsByPublication } = storeToRefs(authorsStore);

fetchAuthorsByPublication(route.params.id as string);

console.log(authorsByPublication);

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

let config = useRuntimeConfig();

const handleClickedPerson = (author: Author, index: number) => {
  if (!config.public.ALLOW_AUTHOR_EDIT) return;
  selectedAuthor.value = author;
  selectedAuthorIndex.value = index;
  showModalAuthor.value = true;
};

const authors = ref([]);

if (route.params.gupid !== "empty" && route.params.gupid !== "error") {
  authors.value = postsCompareMatrix?.value?.find(
    (item) => item.display_type === "authors"
  ).first.value;
} else {
  authors.value = importedPostById?.value?.data?.find(
    (item) => item.display_type === "authors"
  ).first.value;
}

/* authors.value = authors.value.map((author, index) => {
  return {
    id: index,
    isMatch: index % 2 ? true : false,
    year: 1977,
    x_account: "xavgo_" + index,
    full_name: author.name,
    departments: [{ id: 1, name: "bar_foo_" + index }],
  };
}); */

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

function handleRemovePerson(author, index) {
  if (!config.public.ALLOW_AUTHOR_EDIT) return;
  authors.value.splice(index, 1);
}

function handleSuccess() {
  console.log("handleSuccess");
  showModalAuthor.value = false;
}
</script>

<style lang="scss" scoped></style>
