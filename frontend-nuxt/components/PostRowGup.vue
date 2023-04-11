<template>
    <div>
        <NuxtLink :to="{name:'publications-post-id-gup-gupid', query: $route.query, params: {gupid: post.id}}" class="list-group-item list-group-item-action">
            <div class="d-flex w-100 justify-content-between">
                <h5 class="title mb-1">{{ post.title }}</h5>
            </div>
            <p v-if="post.id" class="text-muted mb-2 d-none small">ID: {{ post.id }}</p>
            <p class="mb-0">{{post.pubyear}}</p>
            <small> {{post.publication_type_label}}<br>
                <ul v-if="post.authors" class="list-unstyled list-group list-group-horizontal mb-0">
                    <li v-for="(author, index) in post.authors" :key="author.id">
                        <span class="me-2" v-if="index < 3">
                           <span class="badge bg-secondary">{{ author.name }} </span> 
                        </span>
                    </li>
                    <li v-if="post.authors.length > 3">+ {{ post.authors.length - 3 }}  {{ t('views.publications.post.more_authors') }}</li>
                </ul>
            </small>
        </NuxtLink>
    </div>
</template>

<script setup>
const props = defineProps(['post', 'refresh'])
const {t} = useI18n();

const numerOfAuthors = computed(() => {
    return props.post.authors ? props.post.authors.length : 0;
})


</script>

<style lang="scss" scoped>
.list-group-item  {
    &.router-link-active {
      background: rgb(223, 222, 222);
    }
}

.small {
    font-size: 10px;
}
</style>