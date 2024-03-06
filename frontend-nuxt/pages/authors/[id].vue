<template>
  <div v-if="author">
    <div class="row">
      <h1>{{ authorPrimary?.first_name }} {{ authorPrimary?.last_name }}</h1>
    </div>

    <div id="nameForms" class="row">
      <strong>Namnform(er)</strong>

      <ul class="list-unstyled">
        <li
          class="float-start"
          v-for="(author, index) in author.names"
          :key="author.gup_person_id"
        >
          <a
            :href="`${config.public.API_GUP_BASE_URL_EDIT_AUTHOR}${author.gup_person_id}`"
            >{{ author.first_name }} {{ author.last_name }}</a
          ><span v-if="author.primary" class="ms-1">*</span>
          <span v-if="index < author.names.length - 1" class="me-1 ms-1"
            >|</span
          >
        </li>
      </ul>
    </div>

    <div id="departments" class="row mb-3">
      <div class="col">
        <div class="row mb-3">
          <div class="col">
            <strong>Primär tillhörighet</strong>
            {{ authorCurrentDepartment?.name }}
          </div>
        </div>
        <div class="row">
          <div class="col">
            <strong>Alla affilieringar</strong>
            <ul class="list-unstyled">
              <li
                class="float-start"
                v-for="(department, index) in author.departments"
                x
                :key="department.id"
              >
                {{ department.name }}
                <span
                  v-if="index < author.departments.length - 1"
                  class="me-1 ms-1"
                  >|</span
                >
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <div id="yearOfBirth" class="row mb-3">
      <div class="col">
        <strong>Födelseår</strong> {{ author.year_of_birth }}
      </div>
    </div>

    <div id="identifiers" class="row">
      <div class="col">
        <strong>Identifikatorer</strong>
      </div>
      <ul class="list-unstyled">
        <li v-for="identifier in author.identifiers">
          {{ t(`views.authors.identifier_type.${identifier.code}`) }}:
          {{ identifier.value }}
        </li>
      </ul>
    </div>
  </div>

  <div></div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import type { Nameform, Department, Author } from "../../types/Author";
import { useAuthorsStore } from "../../store/authors";
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";
const { t, getLocale } = useI18n();
const route = useRoute();
const router = useRouter();
const storeAuthor = useAuthorsStore();
const { getAuthorById } = storeAuthor;
getAuthorById(route.params.id as string);
const { author, authors } = storeToRefs(storeAuthor);
console.log(author);

const config = useRuntimeConfig();
console.log(config);

const authorPrimary = computed(() => {
  return author?.value?.names.find(
    (nameForm: Nameform) => nameForm.primary === true
  );
});

const authorSecondary = computed(() => {
  return author?.value?.names.filter(
    (nameForm: Nameform) => nameForm.primary === false
  );
});

const authorCurrentDepartment = computed(() => {
  return author?.value?.departments.find(
    (department: Department) => department.current === true
  );
});
</script>

<style scoped></style>
