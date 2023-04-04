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
            <PostField style="min-height: 100px"> 
                <template v-slot:label>
                    {{ t('views.publications.post.fields.author') }}
                </template>
                <template v-slot:content>
                    <ul v-if="post.authors" class="list-unstyled mb-0">
                    <li v-for="(author, index) in post.authors" :key="author.id">
                        <span v-if="index < numberOfAuthorsToList">
                            {{ author.name }}
                        </span>
                    </li>
                    <li v-if="post.authors.length > numberOfAuthorsToList">+ {{ post.authors.length - numberOfAuthorsToList }}  {{ t('views.publications.post.more_authors') }}</li>
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
const numberOfAuthorsToList = 3;


function getPrefixURL(code) {
    if (code === "doi") {
        return "https://dx.doi.org/"
    } else if (code === "scopus-id") {
        return "https://www.scopus.com/sourceid/";
    } else if (code === "isi-id") {
        return "https://www.webofscience.com/wos/woscc/full-record/WOS:"
    }
}
</script>

<style lang="scss" scoped>

</style>