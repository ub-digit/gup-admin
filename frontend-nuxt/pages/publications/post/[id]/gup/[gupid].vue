<template>
    <div>
        <div class="row">
          <div class="col">
            <h2 class="pb-0 mb-4">{{ gupPostById.title }}</h2>
          </div>
          <div v-if="pendingGupPostById" class="col-auto">
            <Spinner class="me-4"/>            
            </div>
        </div>
        <div class="row">
          <div class="col">
            <PostDisplay :post="gupPostById" />
          </div>
        </div>
    </div>
</template>

<script setup>
import { useGupPostsStore } from '~/store/gup_posts'
import { storeToRefs } from 'pinia'
const {t} = useI18n();
const router = useRouter();
const route = useRoute();

const gupPostsStore = useGupPostsStore()
const { fetchGupPostById } = gupPostsStore
const { gupPostById, pendingGupPostById } = storeToRefs(gupPostsStore)
await fetchGupPostById(route.params.gupid);

//const { data: post, pending, error, refresh } = await useFetch(`/api/post_gup/${route.params.gupid}`);
</script>

<style lang="scss" scoped>

</style>