<template>
    <div>
        <PostMeta class="mb-4" :post="post"/>
        <div class="fields mb-4">
            <PostField>
            <template v-slot:label>
            {{ t('views.publications.post.fields.pubtype') }}
            </template>
            <template v-slot:content>
                {{ post.pubtype }}
            </template>
            </PostField>
            <PostField>
            <template v-slot:label>
                {{ t('views.publications.post.fields.published_in') }}
            </template>
            <template v-slot:content>
                {{ post.pubtype }}
            </template>
            </PostField>
            <PostField>
            <template v-slot:label>
                {{ t('views.publications.post.fields.pubyear') }}
            </template>
            <template v-slot:content>
                {{ post.pubtype }}
            </template>
            </PostField>
            <PostField>
            <template v-slot:label>
                {{ t('views.publications.post.fields.author') }}
            </template>
            <template v-slot:content>
                <ul class="list-unstyled mb-0">
                <li v-for="author in post.authors" :key="author.id">
                    {{ author.name }}
                </li>
                </ul>
            </template>
            </PostField>
            <PostField>
            <template v-slot:label>
                {{ t('views.publications.post.fields.doi') }}
            </template>
            <template v-slot:content>
                <a :href="post.doi" target="_blank">{{ post.doi }}</a>
            </template>
            </PostField>
            <PostField>
            <template v-slot:label>
                {{ t('views.publications.post.fields.scopus') }}
            </template>
            <template v-slot:content>
                <span v-if="post.scopus_id">
                <a :href="post.scopus_id">{{ post.scopus_id }}</a>
                </span>
                <span class="badge bg-danger" v-else>
                {{ t('views.home.post.fields.scopus_missing')  }}
                </span>
            </template>
            </PostField>
        </div>
    </div>
</template>

<script setup>
const {t} = useI18n();
const props = defineProps(['post']);

</script>

<style lang="scss" scoped>

</style>