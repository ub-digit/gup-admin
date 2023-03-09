<template>
    <div>
        <div class="row">
          <div class="col">
            <h2 class="pb-0 mb-4">{{ post.title }}</h2>
          </div>
          <div v-if="pending" class="col-auto">
            <Spinner class="me-4"/>            
            </div>
        </div>
        <div class="row">
          <div class="col">
            <PostDisplay :post="post" />
          </div>
        </div>
    </div>
</template>

<script setup>
const {t} = useI18n();
const router = useRouter();
const route = useRoute();
const { data: post, pending, error, refresh } = await useFetch(`/api/post_gup/${route.params.gupid}`);
</script>

<style lang="scss" scoped>

</style>