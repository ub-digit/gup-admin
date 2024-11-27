<template>
  <div class="row" v-if="author">
    <div class="col-6">
      <div class="row">
        <h1>{{ authorPrimary?.first_name }} {{ authorPrimary?.last_name }}</h1>
      </div>

      <div id="nameForms" class="row mb-3">
        <div class="col">
          <strong>Namnform(er):</strong>
        </div>
        <div class="col">
          <ul class="list-unstyled">
            <li
              class="float-start"
              v-for="(item, index) in author.names"
              :key="item.gup_person_id"
            >
              <a
                :href="`${config.public.API_GUP_BASE_URL}/admin/people/person/edit/${item.gup_person_id}`"
                >{{ item.first_name }} {{ item.last_name }}</a
              ><span v-if="item.primary" class="ms-1"
                ><span class="badge text-bg-primary">Primär</span></span
              >
              <span v-if="index < author.names.length - 1" class="me-1 ms-1"
                >|</span
              >
            </li>
          </ul>
        </div>
      </div>

      <div id="departments" class="row mb-3">
        <div class="col">
          <div class="row mb-3">
            <div class="col">
              <strong>Primär tillhörighet:</strong>
            </div>
            <div class="col">
              <span v-if="authorCurrentDepartment">
                {{ authorCurrentDepartment?.name }}
              </span>
              <span v-else> Saknas </span>
            </div>
          </div>
          <div class="row">
            <div class="col">
              <strong>Alla tillhörigheter:</strong>
            </div>
            <div class="col">
              <ul v-if="author?.departments?.length" class="list-unstyled">
                <li
                  class="float-start"
                  v-for="(department, index) in author.departments"
                  x
                  :key="department.id"
                >
                  {{ department.name }}
                  <span v-if="department.current" class="ms-1">*</span>
                  <span
                    v-if="index < author.departments.length - 1"
                    class="me-1 ms-1"
                    >|</span
                  >
                </li>
              </ul>
              <span v-else> Saknas </span>
            </div>
          </div>
        </div>
      </div>

      <div id="yearOfBirth" class="row mb-3">
        <div class="col">
          <strong>Födelseår:</strong>
        </div>
        <div class="col">
          <span v-if="author?.year_of_birth">{{ author.year_of_birth }}</span>
          <span v-else> Saknas </span>
        </div>
      </div>

      <div id="identifiers" class="row">
        <div class="col pt-2 pb-2" style="border: 1px solid #ccc">
          <div class="row">
            <div class="col">
              <strong>Identifikatorer:</strong>
            </div>
            <div class="col">
              <div v-if="author?.identifiers?.length" class="row">
                <div class="row" v-for="identifier in author.identifiers">
                  <div class="col">
                    {{ t(`views.authors.identifier_type.${identifier.code}`) }}:
                  </div>
                  <div class="col">{{ identifier.value }}</div>
                </div>
              </div>
              <span v-else>Saknas</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
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
  const primaryAuthor = author?.value?.names.find(
    (nameForm: Nameform) => nameForm.primary === true
  );
  if (primaryAuthor) {
    return primaryAuthor;
  } else {
    return author?.value?.names[0];
  }
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
