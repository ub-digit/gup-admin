<template>
  <ModalAuthor
    v-if="showModalAuthor"
    :noSuccessButton="false"
    :show="showModalAuthor"
    :sourceSelectedAuthor="selectedAuthor"
    :publicationYear="publicationYear"
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
  <button class="btn btn-primary" @click="addAuthor()">Lägg till rad +</button>
</template>

<script setup lang="ts">
import { useComparePostsStore } from "~/store/compare_posts";
import { useImportedPostsStore } from "~/store/imported_posts";
import { storeToRefs } from "pinia";
import type { AuthorAffiliation } from "~/types/Publication";
import { ref } from "vue";
import type { Ref } from "vue";

let showModalAuthor = ref(false);
let selectedAuthor: Ref<AuthorAffiliation | null> = ref(null);
let selectedAuthorIndex: Ref<number | null> = ref(null);
let publicationYear: Ref<string | null> = ref(null);

const route = useRoute();

const importedPostsStore = useImportedPostsStore();
const { importedPostById } = storeToRefs(importedPostsStore);

const { fetchAuthorsByPublication, addEmptyAuthorToPublication } =
  importedPostsStore;
const { authorsByPublication } = storeToRefs(importedPostsStore);

fetchAuthorsByPublication(route.params.id as string);

const comparePostsStore = useComparePostsStore();
const { postsCompareMatrix } = storeToRefs(comparePostsStore);

let config = useRuntimeConfig();

const handleClickedPerson = (author: AuthorAffiliation, index: number) => {
  if (!config.public.ALLOW_AUTHOR_EDIT) return;
  selectedAuthor.value = author;
  selectedAuthorIndex.value = index;
  showModalAuthor.value = true;
};

const authors = ref([]);

if (route.params.gupid !== "empty" && route.params.gupid !== "error") {
  publicationYear.value = postsCompareMatrix?.value?.find(
    (item) => item?.display_label === "pubyear"
  ).first.value as string;
} else {
  publicationYear.value = importedPostById?.value?.data?.find(
    (item) => item?.display_label === "pubyear"
  ).first.value as string;
}

function addAuthor() {
  if (!config.public.ALLOW_AUTHOR_EDIT) return;
  addEmptyAuthorToPublication();
}

function handleAuthorSelected(author: AuthorAffiliation) {
  if (author) {
    authorsByPublication.value.splice(
      selectedAuthorIndex?.value as number,
      1,
      author
    );
    selectedAuthorIndex.value = null;
  }
  showModalAuthor.value = false;
}

function handleMoveUp(author: AuthorAffiliation, index: number) {
  if (index > 0) {
    const temp = authorsByPublication.value[index - 1];
    authorsByPublication.value[index - 1] = author;
    authorsByPublication.value[index] = temp;
  }
}

function handleMoveDown(author: AuthorAffiliation, index: number) {
  if (index < authorsByPublication.value.length - 1) {
    const temp = authorsByPublication.value[index + 1];
    authorsByPublication.value[index + 1] = author;
    authorsByPublication.value[index] = temp;
  }
}

function handleRemovePerson(author: AuthorAffiliation, index: number) {
  if (!config.public.ALLOW_AUTHOR_EDIT) return;
  authorsByPublication.value.splice(index, 1);
}

function handleSuccess() {
  console.log("handleSuccess");
  showModalAuthor.value = false;
}
</script>

<style lang="scss" scoped></style>
