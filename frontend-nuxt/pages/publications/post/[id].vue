<template>
      <div class="col-6">
         <ErrorLoadingPost v-if="errorImportedPostById" :error="errorImportedPostById"/> 
        <div v-else>
          <div class="row">
            <div class="col" :class="{'opacity-50' :pendingImportedPostById}">
              <h2 class="pb-0 mb-4">{{ importedPostById.title }}</h2>
            </div>
            <div class="col-auto">
              <Spinner v-if="pendingGupPostsByTitle || pendingGupPostsById || pendingImportedPostById" class="me-4"/>            
              </div>
          </div>
          <div class="row">
            <div class="col">
              <PostDisplay :class="{'opacity-50' :pendingImportedPostById}" :post="importedPostById" />
            </div>
          </div>
          <div class="row pb-4">
            <div class="col text-end">
              <button type="button" class="btn btn-danger me-1" @click="removePost">{{t('buttons.remove')}}</button>
              <button type="button" class="btn btn-secondary me-1" @click="editPost">{{t('buttons.edit')}}</button>
              <button type="button" class="btn btn-success" @click="mergePosts">{{t('buttons.merge')}}</button>
            </div>
          </div>

          <h3 class="mb-4">{{ t('views.publications.post.result_list.header') }}</h3>

          <div class="row pb-4">
            <div class="col">
              <h4 class="mb-1 text-muted">{{ t('views.publications.post.result_list_by_id.header') }}</h4>
              <div v-if="!gupPostsById.length">{{ t('views.publications.post.result_list.no_gup_posts_by_id_found') }}</div>
              <div v-else :class="{'opacity-50' :pendingGupPostsById}" class="list-group list-group-flush border-bottom">
                <PostRowGup v-for="post in gupPostsById" :post="post" :refresh="$route.query" :key="post.id"/>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col">
              <div class="row">
                <div class="col">
                  <h4 class="mb-1 text-muted">{{ t('views.publications.post.result_list_by_title.header') }}</h4>
                </div>
                <div class="col-auto">
                  <Spinner v-if="pendingGupPostsByTitle" class="me-4"/>            
                </div>
              </div>
              <div class="row">
                <div class="col">
                  <label class="d-none" for="title-search">Sök på titel</label>
                  <input id="title-search" class="form-control mb-3" type="search" v-model="searchTitleStr">
                  <div v-if="!gupPostsByTitle.length">{{ t('views.publications.post.result_list.no_gup_posts_by_title_found') }}</div>
                  <div v-else :class="{'opacity-50': pendingGupPostsByTitle}" class="list-group list-group-flush border-bottom">
                    <PostRowGup v-for="post in gupPostsByTitle" :post="post" :key="post.id"/>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
      <div class="col-6">
        <NuxtPage/>
      </div>
</template>

<script setup>
import { useDebounceFn } from '@vueuse/core'
import { useGupPostsStore } from '~/store/gup_posts'
import { useImportedPostsStore } from '~/store/imported_posts'
import { useFilterStore } from '~~/store/filter'
import { storeToRefs } from 'pinia'
const {t} = useI18n();
const route = useRoute();
const router = useRouter();
const searchTitleStr = ref(null);

  const filterStore = useFilterStore();

  const importedPostsStore = useImportedPostsStore();
  const {fetchImportedPostById, removeImportedPost, fetchImportedPosts} = importedPostsStore;
  const {importedPostById, pendingImportedPostById, errorImportedPostById} = storeToRefs(importedPostsStore) 

  const gupPostsStore = useGupPostsStore()
  const { fetchGupPostsByTitle, fetchGupPostsById } = gupPostsStore
  const { gupPostsByTitle, pendingGupPostsByTitle, gupPostsById, pendingGupPostsById, gupPostById, pendingGupPostById } = storeToRefs(gupPostsStore)

  await fetchImportedPostById(route.params.id);
  searchTitleStr.value = importedPostById.value ? importedPostById.value.title : "";
  
  if (importedPostById.value) {
    await fetchGupPostsById(importedPostById.value.id);
    await fetchGupPostsByTitle(importedPostById.value.id, importedPostById.value.title);
  }
  
  
  const debounceFn = useDebounceFn(() => {
    if (importedPostById ) {
      fetchGupPostsByTitle({title: searchTitleStr.value});
    }
  }, 500)
 
  watch(
    searchTitleStr,
  () => {
    debounceFn();
  }
)

function mergePosts() {
  alert("merge")
}
async function removePost() {
  const ok = confirm("Är du säker på att du vill ta bort den importerade posten?")
  if (ok) {
    const res = await removeImportedPost(importedPostById.value.id);
    fetchImportedPosts();
    router.push({ path: '/publications', query: { ...route.query } })
  }
}
function editPost() {
  alert("Edit in GUP")
}
</script>

<style lang="scss" scoped>

</style>