<template>
  <Head>
    <title>{{ t("seo.application_title") }} - författare</title>
    <Meta name="description" :content="t('seo.application_title')" />
  </Head>
  <div>
    <div class="container-fluid">
      <div class="row">
        <div class="col-4 me-2">
          <div class="row">
            <form class="col mb-3" id="filters">
              <label for="search_name" class="form-label visually-hidden"
                >Sök författare</label
              >
              <input
                ref="input_search_name"
                name="search_name"
                id="search_name"
                type="search"
                v-model="filters.name"
                class="form-control"
                aria-placeholder="Sök författare"
                placeholder="Sök författare"
              />
            </form>
            <!--             <FilterAuthor :pendingAuthors="pendingAuthors" />  -->
          </div>
          <div class="row">
            <div class="col opacity-50 text-center mb-4">
              <strong>
                55555
                {{ t("views.publications.result_list.meta.of") }}
                99999
                {{ t("views.publications.result_list.meta.posts") }}</strong
              >
            </div>
          </div>
          <div id="result-list" class="row">
            <div class="col scroll" :class="{ 'opacity-50': pendingAuthors }">
              <div v-if="authors && !authors.length">
                Hittade inga författare
              </div>
              <div v-else class="list-group list-group-flush border-bottom">
                <AuthorListRow
                  v-for="author in authors"
                  :author="author"
                  :key="author.id"
                />
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <div class="row">
            <NuxtPage />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useAuthorsStore } from "~/store/authors";
const input_search_name = ref<HTMLInputElement | null>(null);
const { t, getLocale } = useI18n();
const storeAuthor = useAuthorsStore();
const { fetchAuthors } = storeAuthor;
fetchAuthors();
const { authors, pendingAuthors, filters } = storeToRefs(storeAuthor);

watchEffect(() => {
  if (input_search_name.value) {
    input_search_name.value.focus();
  }
});
</script>

<style lang="scss" scoped>
.scroll {
  max-height: 100vh;
  overflow-y: scroll;
}
</style>
