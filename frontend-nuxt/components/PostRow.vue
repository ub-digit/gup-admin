<template>
    <div>
        <NuxtLink :to="{name:'home-post-id', query: $route.query, params: {id: post.gup_id}}" class="list-group-item list-group-item-action">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="title mb-1">{{ post.title }}</h5>
                <small class="text-muted">GUP-ID: {{ post.gup_id }}</small>
            </div>
            <p class="mb-0">{{post.date}}</p>
            <small>{{post.pubtype}}<br>
            {{ post.number_of_authors }} författare</small>
        </NuxtLink>
    </div>
</template>

<script setup>
const props = defineProps(['post', 'refresh'])
const {t} = useI18n();


</script>

<style lang="scss" scoped>

</style>