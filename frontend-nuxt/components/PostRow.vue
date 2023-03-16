<template>
    <div>
        <NuxtLink :to="{name:'publications-post-id', query: $route.query, params: {id: post.id}}" class="list-group-item list-group-item-action">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="title mb-1">{{ post.title }}</h5>
                <small v-if="post.gup_id" class="text-muted">GUP-ID: {{ post.gup_id }}</small>
            </div>
            <p class="mb-0">{{post.date}}</p>
            <small>Pubtype: {{post.pubtype}}<br>
            {{ post.number_of_authors }} författare</small>
        </NuxtLink>
    </div>
</template>

<script setup>
const props = defineProps(['post'])
const {t} = useI18n();


</script>

<style lang="scss" scoped>
.list-group-item  {
    &.router-link-active {
      background: rgb(223, 222, 222);
    }
}

</style>