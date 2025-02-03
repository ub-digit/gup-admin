<template>
  <h2>Redigera person</h2>
  <AuthorForm
    :author="author as Author"
    :errors="errors"
    @submit="saveAuthor"
    @onCancel="cancelEdit"
    submitBtnText="Spara"
  />

  <div class="row mt-5">
    <div class="col">
      <h3>Submitted data (debug)</h3>
      <pre>{{ submittedData }}</pre>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import type { Author, Nameform } from "~/types/Author";
import { useAuthorsStore } from "~/store/authors";
import type { Ref } from "vue";

const route = useRoute();
const router = useRouter();
const storeAuthor = useAuthorsStore();
const { author } = storeToRefs(storeAuthor);
const { fetchAuthorById, updateAuthor } = storeAuthor;
const submittedData: Ref<Author | null> = ref(null);
const errors: Ref<string[]> = ref([]);

await fetchAuthorById(route.params.id as string);

const saveAuthor = async (data: Author) => {
  const res = await updateAuthor(route.params.id as string, data);
  if (res?.status === "success") {
    router.push({
      name: "authors-id",
      params: { id: route.params.id },
      query: { ...route.query },
    });
  } else if (res?.status === "error") {
    errors.value = res.errors;
    window.scrollTo(0, 0);
  }
};

const cancelEdit = () => {
  router.push({
    name: "authors-id",
    params: { id: route.params.id },
    query: { ...route.query },
  });
};
</script>

<style scoped></style>
