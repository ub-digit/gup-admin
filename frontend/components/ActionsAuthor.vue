<template>
  <div>
    <div class="row">
      <div class="col d-flex justify-content-end">
        <NuxtLink
          class="btn btn-link"
          :to="{
            name: 'authors-id-edit',
            query: $route.query,
            params: { id: author.id },
          }"
        >
          Redigera
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import type { Nameform, Department, Author } from "~/types/Author";
import { useAuthorsStore } from "~/store/authors";
const storeAuthor = useAuthorsStore();
const { author } = storeToRefs(storeAuthor);
</script>

<style scoped></style>
