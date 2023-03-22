<template>
    <div>
        <PostMeta class="mb-4" :post="post"/>
        <div class="fields mb-4">
            <PostField>
                <template v-slot:label>
                {{ t('views.publications.post.fields.pubtype') }}
                </template>
                <template v-slot:content>
                    {{ post.publication_type_label }}
                </template>
            </PostField>
            <PostField>
                <template v-slot:label>
                    {{ t('views.publications.post.fields.published_in') }}
                </template>
                <template v-slot:content>
                    {{ post.sourcetitle }}
                </template>
            </PostField>
            <PostField>
                <template v-slot:label>
                    {{ t('views.publications.post.fields.pubyear') }}
                </template>
                <template v-slot:content>
                    {{ post.pubyear }}
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

            <PostField v-for="identifier in post.publication_identifiers" :key="identifier.id">
                <template v-slot:label>
                    {{identifier.identifier_label}}
                </template>
                <template v-slot:content>
                    <span v-if="getPrefixURL(identifier.identifier_code)" >
                        <a :href="`${getPrefixURL(identifier.identifier_code)}${identifier.identifier_value}`" target="_blank">{{ identifier.identifier_value }}</a>
                    </span>
                    <span v-else>
                        {{ identifier.identifier_value }}
                    </span>
                </template>
            </PostField>
           <!-- <PostField>  
                <template v-slot:label>
                    {{ t('views.publications.post.fields.scopus') }}
                </template>
                <template v-slot:content>
                    <span v-if="post.scopus_id">
                    <a :href="post.scopus_id">{{ post.scopus_id }}</a>
                    </span>
                    <span class="badge bg-danger" v-else>
                    {{ t('views.publications.post.fields.scopus_missing')  }}
                    </span>
                </template>
            </PostField> -->
        </div>
    </div>
</template>

<script setup>
const {t} = useI18n();
const props = defineProps(['post']);


function getPrefixURL(code) {
    if (code === "doi") {
        return "https://dx.doi.org/"
    } else if (code === "scopus-id") {
        return "";
    }
}
</script>

<style lang="scss" scoped>

</style>