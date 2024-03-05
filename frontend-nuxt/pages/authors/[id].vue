<template>
  <div v-if="current_author" class="row">
    <div>
      <strong
        >{{ authorPrimary?.first_name }} {{ authorPrimary?.last_name }}</strong
      >
      + {{ current_author?.names.length - 1 }} ytterligare namnform(er)
    </div>
    <div>{{ current_author.year_of_birth }}</div>
    <div>
      <strong> {{ authorCurrentDepartment?.name }}</strong> +
      {{ current_author.departments.length - 1 }} yttterligare
    </div>
    <br />
    <br />
    <div>
      <ul class="list-unstyled">
        <li v-for="identifier in current_author.identifiers">
          {{ identifier.code }}: {{ identifier.value }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import type { Nameform, Department, Author } from "../../types/Author";
import { useAuthorsStore } from "../../store/authors";
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";
const route = useRoute();
const router = useRouter();
const storeAuthor = useAuthorsStore();
const { getAuthorById } = storeAuthor;
getAuthorById(route.params.id as string);
const { current_author, authors } = storeToRefs(storeAuthor);
console.log(current_author);

const authorPrimary = computed(() => {
  return current_author?.value?.names.find(
    (nameForm: Nameform) => nameForm.primary === true
  );
});

const authorCurrentDepartment = computed(() => {
  return current_author?.value?.departments.find(
    (department: Department) => department.current === true
  );
});
</script>

<style scoped></style>
