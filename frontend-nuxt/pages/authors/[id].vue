<template>
  <div class="row" v-if="author">
    <div class="col-6">
      <div class="row">
        <h1>{{ authorPrimary?.first_name }} {{ authorPrimary?.last_name }}</h1>
      </div>

      <div id="nameForms" class="row">
        <strong>Namnform(er)</strong>

        <ul class="list-unstyled">
          <li
            class="float-start"
            v-for="(item, index) in author.names"
            :key="item.gup_person_id"
          >
            <a
              :href="`${config.public.API_GUP_BASE_URL}/admin/people/person/edit/${item.gup_person_id}`"
              >{{ item.first_name }} {{ item.last_name }}</a
            ><span v-if="item.primary" class="ms-1">*</span>
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
              <span v-if="authorCurrentDepartment">
                {{ authorCurrentDepartment?.name }}
              </span>
              <span v-else> Saknar primär avdelning </span>
            </div>
          </div>
          <div class="row">
            <div class="col">
              <strong>Alla tillhörigheter</strong>
              <ul class="list-unstyled">
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
          <div class="row">
            <div class="col">
              <strong>Identifikatorer</strong>
            </div>
          </div>

          <div class="row">
            <div class="col">
              <table class="table">
                <tbody>
                  <tr v-for="identifier in author.identifiers">
                    <th scope="row">
                      {{
                        t(`views.authors.identifier_type.${identifier.code}`)
                      }}:
                    </th>
                    <td>{{ identifier.value }}</td>
                  </tr>
                </tbody>
              </table>
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
