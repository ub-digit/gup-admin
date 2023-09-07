<template>
  <div>
    <Head>
      <title>{{ t("seo.application_title") }}</title>
      <Meta name="description" :content="t('seo.application_title')" />
    </Head>
    <div class="container-fluid">
      <div class="row">
        <div class="col-4 me-2">
          <div class="row">
            <Filters :pendingImportedPosts="pendingImportedPosts" />
          </div>
          <div class="row">
            <div class="col opacity-50 text-center mb-4">
              <strong>
                {{ importedPosts.showing }}
                {{ t("views.publications.result_list.meta.of") }}
                {{ importedPosts.total }}
                {{ t("views.publications.result_list.meta.posts") }}</strong
              >
            </div>
          </div>
          <div id="result-list-by-id" class="row">
            <div
              class="col scroll"
              :class="{ 'opacity-50': pendingImportedPosts }"
            >
              <div v-if="importedPosts.data && !importedPosts.data.length">
                {{
                  t("views.publications.result_list.no_imported_posts_found")
                }}
              </div>
              <div v-else class="list-group list-group-flush border-bottom">
                <PostRow
                  v-for="post in importedPosts.data"
                  :post="post"
                  :key="post.id"
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

<script setup>
import { useImportedPostsStore } from "~/store/imported_posts";
import { storeToRefs } from "pinia";
import _ from "lodash";
const { t, getLocale } = useI18n();
const config = useRuntimeConfig();
const route = useRoute();
const router = useRouter();

const importedPostsStore = useImportedPostsStore();
const { fetchImportedPosts } = importedPostsStore;
const { importedPosts, pendingImportedPosts } = storeToRefs(importedPostsStore);
await fetchImportedPosts();
</script>

<style lang="scss">
.scroll {
  max-height: 800px;
  overflow-y: scroll;
}
</style>
