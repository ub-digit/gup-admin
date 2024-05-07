<template>
  <div class="row" v-if="author">
    <div class="col-6">
      <div class="row">
        <h1>{{ authorPrimary?.first_name }} {{ authorPrimary?.last_name }}</h1>
      </div>

      <div id="nameForms" class="row mb-3">
        <div class="col-4">
          <strong>Namnform(er)</strong>
        </div>
        <div class="col">
          <ul class="list-unstyled">
            <li
              class="float-start"
              v-for="(item, index) in author.names"
              :key="index"
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
      </div>

      <div id="departments" class="row mb-3">
        <div class="col">
          <div class="row mb-3">
            <div class="col-4">
              <strong>Primär tillhörighet</strong>
            </div>
            <div class="col">
              <span v-if="authorCurrentDepartment">
                {{ authorCurrentDepartment?.name }}
              </span>
              <span v-else> Saknas </span>
            </div>
          </div>
          <div class="row">
            <div class="col-4">
              <strong>Alla tillhörigheter</strong>
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
        <div class="col-4">
          <strong>Födelseår</strong>
        </div>
        <div class="col">
          <span v-if="author?.year_of_birth"
            >&nbsp;{{ author.year_of_birth }}</span
          >
          <span v-else> Saknas </span>
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
              <table v-if="author?.identifiers?.length" class="table ms-2">
                <tbody>
                  <tr v-for="identifier in author.identifiers">
                    <th scope="row">
                      {{
                        t(`views.authors.identifier_type.${identifier.code}`)
                      }}
                    </th>
                    <td>{{ identifier.value }}</td>
                  </tr>
                </tbody>
              </table>
              <span v-else>Saknas</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-6">
      <h2>Publikationer i GUP</h2>
      <div id="search-form" class="mb-2 d-none">
        <label class="form-label" for="author-search"
          >Sök efter publikationer i GUP</label
        >
        <input
          id="author-search"
          class="form-control"
          type="search"
          v-model="searchTerm"
          placeholder="Sök efter publikationer i GUP"
        />
      </div>
      <Spinner v-if="pendingGupPostsByAuthors" />
      <div
        :class="{ 'opacity-50': pendingGupPostsByAuthors }"
        class="list-group list-group-flush border-bottom"
      >
        <PostRowGup
          v-for="post in gupPostsByAuthors"
          :post="post"
          :refresh="$route.query"
          :key="post.id"
          :linkToGup="true"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useDebounceFn } from "@vueuse/core";
import { storeToRefs } from "pinia";
import type { Nameform, Department, Author } from "../../types/Author";
import { useAuthorsStore } from "../../store/authors";
import { useComparePostsStore } from "~/store/compare_posts";
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";
const { t, getLocale } = useI18n();
const route = useRoute();
const router = useRouter();
const storeAuthor = useAuthorsStore();
const storeComparePosts = useComparePostsStore();
const { fetchGupPostsByAuthors } = storeComparePosts;
//fetchGupPostsByAuthors();
const { gupPostsByAuthors, pendingGupPostsByAuthors } =
  storeToRefs(storeComparePosts);
const { getAuthorById } = storeAuthor;
getAuthorById(route.params.id as string);
const { author, authors } = storeToRefs(storeAuthor);
console.log(author);

const config = useRuntimeConfig();

const authorGupID = computed(() => {
  let gup_person_ids: (number | undefined | null)[] | undefined =
    author.value?.names.map((name: Nameform) => name?.gup_person_id);
  return gup_person_ids?.join(",");
});

const searchTerm: Ref<string | undefined> = ref("");

const debounceFn = useDebounceFn(() => {
  if (searchTerm) {
    fetchGupPostsByAuthors();
  }
}, 500);

watch(authorGupID, () => {
  searchTerm.value = authorGupID.value;
});

watch(searchTerm, () => {
  debounceFn();
});

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
