<template>
<div>
    <div class="row">
      <!-- use the modal component, pass in the prop -->
      <modal :show="showModal" @success="handleSuccess" @close="showModal = false">
        <template #header>
          <h4>{{t('messages.create_in_gup_success')}}</h4>
        </template>
        <template #body>
          <p>{{t('messages.create_in_gup_success_body')}}</p>
        </template>
      </modal>

      <div v-if="route.params.gupid !== 'empty'"> 
        <PostDisplayCompare :dataMatrix="gupCompareImportedMatrix" />
      </div>
      <div class="row" v-else>      
        <div class="col-6">
          <PostDisplayCompare :dataMatrix="importedPostById" />
       <!--   <ErrorLoadingPost v-if="errorImportedPostById" :error="errorImportedPostById"/> 
          <div v-if="importedPostById">
            <div class="row">
                <div class="col" :class="{'opacity-50' :pendingImportedPostById}">
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
                <button :disabled="!gupPostById.id" type="button" class="btn btn-success" @click="mergePosts">{{t('buttons.merge')}}</button>
              </div>
            </div>
            <div class="row">
              <h3 class="mb-4">{{ t('views.publications.post.result_list.header') }}</h3>
            </div>

            <div class="row pb-4">
              <div class="col">
                <h4 class="mb-1 text-muted">{{ t('views.publications.post.result_list_by_id.header') }}</h4>
                <div v-if="gupPostsById.data && !gupPostsById.data.length">{{ t('views.publications.post.result_list.no_gup_posts_by_id_found') }}</div>
                <div v-else :class="{'opacity-50' :pendingGupPostsById}" class="list-group list-group-flush border-bottom">
                  <PostRowGup v-for="post in gupPostsById.data" :post="post" :refresh="$route.query" :key="post.id"/>
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
                    <div v-if="gupPostsByTitle.data && !gupPostsByTitle.data.length">{{ t('views.publications.post.result_list.no_gup_posts_by_title_found') }}</div>
                    <div v-else :class="{'opacity-50': pendingGupPostsByTitle}" class="list-group list-group-flush border-bottom">
                      <PostRowGup v-for="post in gupPostsByTitle.data" :post="post" :key="post.id"/>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div> -->
        </div> 
        <div class="col-6">
          <NothingSelected/>
        </div>
      </div>



<!--       <div class="col-6">
        <div v-if="route.params.gupid === 'empty'">
          <NothingSelected/>
        </div>
        <div v-else>
          <ErrorLoadingPost v-if="errorGupPostById" :error="errorGupPostById"/>
          <div v-else>
            <div class="row">
              <div class="col" v-if="gupPostById.id">
                <PostDisplayTitle :title="gupPostById.title" :url="gupURL"/>
        
              </div>
              <div v-if="pendingGupPostById" class="col-auto">
                <Spinner class="me-4"/>            
                </div>
            </div>
            <div class="row">
              <div class="col" v-if="gupPostById">
                <PostDisplay :post="gupPostById" />
              </div>
            </div>
          </div>
        </div>
      </div> -->
  </div>
  <div class="row pb-4 mt-4">
      <div class="col-6 text-end">
        <button type="button" class="btn btn-danger me-1" @click="removePost">{{t('buttons.remove')}}</button>
        <button type="button" class="btn btn-secondary me-1" @click="editPost">{{t('buttons.edit')}}</button>
        <button :disabled="!gupPostById.id" type="button" class="btn btn-success" @click="mergePosts">{{t('buttons.merge')}}</button>
      </div>
  </div>

  <div class="row">
    <div class="col-6">
      <h3 class="mb-4">{{ t('views.publications.post.result_list.header') }}</h3>
    </div>
  </div>

  <div class="row pb-4">
    <div class="col-6">
      <h4 class="mb-1 text-muted">{{ t('views.publications.post.result_list_by_id.header') }}</h4>
      <div v-if="gupPostsById.data && !gupPostsById.data.length">{{ t('views.publications.post.result_list.no_gup_posts_by_id_found') }}</div>
      <div v-else :class="{'opacity-50' :pendingGupPostsById}" class="list-group list-group-flush border-bottom">
        <PostRowGup v-for="post in gupPostsById.data" :post="post" :refresh="$route.query" :key="post.id"/>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-6">
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
          <div v-if="gupPostsByTitle.data && !gupPostsByTitle.data.length">{{ t('views.publications.post.result_list.no_gup_posts_by_title_found') }}</div>
          <div v-else :class="{'opacity-50': pendingGupPostsByTitle}" class="list-group list-group-flush border-bottom">
            <PostRowGup v-for="post in gupPostsByTitle.data" :post="post" :key="post.id"/>
          </div>
        </div>
      </div>
    </div>
  </div>
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
const { $toast } = useNuxtApp();
const config = useRuntimeConfig();
const showModal = ref(false);

  const filterStore = useFilterStore();

  const importedPostsStore = useImportedPostsStore();
  const {fetchImportedPostById, removeImportedPost, fetchImportedPosts, createImportedPostInGup} = importedPostsStore;
  const {importedPostById, pendingImportedPostById, pendingCreateImportedPostInGup, errorImportedPostById} = storeToRefs(importedPostsStore) 

  const gupPostsStore = useGupPostsStore()
  const { fetchGupPostsByTitle, fetchGupPostsById } = gupPostsStore
  const { gupPostsByTitle, pendingGupPostsByTitle, gupPostsById, pendingGupPostsById, gupPostById, gupCompareImportedMatrix, pendingGupPostById, errorGupPostById } = storeToRefs(gupPostsStore)

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

function sanitizeID(id) {
  return  id.replace("gup_","");
} 

function mergePosts() {
  alert("merge")
}
async function removePost() {
  const ok = confirm(t('messages.confirm_remove'))
  if (ok) {
    const response = await removeImportedPost(importedPostById.value.id);
    fetchImportedPosts();
    $toast.success(t('messages.remove_success'));
    router.push({ path: '/publications', query: { ...route.query } })
  }
}


async function handleSuccess() {
  const response = await removeImportedPost(importedPostById.value.id);
  fetchImportedPosts();
  showModal.value = false;
  $toast.success(t('messages.remove_success'));
  router.push({path: '/publications', query: {...route.query}})
}

async function editPost() {
  const ok = confirm(t('messages.confirm_create_in_gup'))
  if (ok) {
    if (importedPostById.value.source !== "gup") {
      const response = await createImportedPostInGup(importedPostById.value.id)
      if (response) {
        //$toast.success(t('messages.create_in_gup_success') + `<br> GUP-ID: ${response.id}`, {duration: 0});
        const url = config.public.API_GUP_BASE_URL_EDIT + response.id;
        window.open(url, '_blank')
        showModal.value = true;
      }
    } else if (importedPostById.value.source === "gup") {
      window.open(`${config.public.API_GUP_BASE_URL_EDIT}${sanitizeID(importedPostById.value.id)}`, '_blank')
    }
  } 
}

const { fetchCompareGupPostWithImported, $reset} = gupPostsStore
if (route.params.gupid !== "empty") {
  const res = await fetchCompareGupPostWithImported(route.params.id, route.params.gupid);
} else {
  $reset()
}

const gupURL = computed(() => {
  return `${config.public.API_GUP_BASE_URL_SHOW}${gupPostById.value.publication_id}`; 
})

//const { data: post, pending, error, refresh } = await useFetch(`/api/post_gup/${route.params.gupid}`);
</script>

<style lang="scss" scoped>
.col {

}
</style>