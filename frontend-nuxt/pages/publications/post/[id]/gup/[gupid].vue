<template>
    <div>
      <ErrorLoadingPost v-if="errorGupPostById" :error="errorGupPostById"/>
      <div v-else>
        <div class="row">
          <div class="col" v-if="gupPostById">
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
</template>

<script setup>
import { useGupPostsStore } from '~/store/gup_posts'
import { storeToRefs } from 'pinia'
import { onMounted, onUnmounted } from 'vue'
const {t} = useI18n();
const router = useRouter();
const route = useRoute();
const gupPostsStore = useGupPostsStore()
const { fetchGupPostById, $reset} = gupPostsStore
const { gupPostById, pendingGupPostById, errorGupPostById} = storeToRefs(gupPostsStore)
await fetchGupPostById(route.params.gupid);

const gupURL = computed(() => {
  console.log(gupPostById)
  return `https://gup.ub.gu.se/publications/show/${gupPostById.value.publication_id}`; 
})

onUnmounted(() => {
  //$reset()
})



//const { data: post, pending, error, refresh } = await useFetch(`/api/post_gup/${route.params.gupid}`);
</script>

<style lang="scss" scoped>
.col {
  
}
</style>