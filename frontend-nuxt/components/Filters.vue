<template>
    <div>
        <form class="col" @submit.prevent=void(0) id="filters">
              <div class="row">
                <div class="col">
                  <div class="form-check col-auto form-switch mb-3">
                    <input class="form-check-input" type="checkbox" id="needs_attention" v-model="filters.needs_attention">
                    <label class="form-check-label" for="needs_attention">{{ t('views.publications.form.needs_attention') }}</label>
                  </div>
                </div>
                <div class="col-auto">
                  <Spinner v-if="pendingImportedPosts" class="me-4" />
                </div>
              </div>
              <div class="mb-3">
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="checkbox" id="scopus" v-model="filters.scopus">
                  <label class="form-check-label" for="scopus">{{ t('views.publications.form.scopus_title') }}</label>
                </div>

                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="checkbox" id="wos" v-model="filters.wos">
                  <label class="form-check-label" for="wos">{{ t('views.publications.form.wos_title') }}</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="checkbox" id="manual" v-model="filters.manual">
                  <label class="form-check-label" for="manual">{{ t('views.publications.form.manual_title') }}</label>
                </div>
              </div>
              <select class="form-select mb-3" v-model="filters.pubtype" :aria-label="t('views.publications.form.pub_type_select_label')">
                <option value="" selected>{{ t('views.publications.form.pub_type_select_label') }}</option>
                <option v-for="pubtype in publicationTypes" :value="pubtype.id" :key="pubtype.id">
                  {{ pubtype.display_name }}
                </option>
              </select>

              <div class="mb-3">
                <label for="title" class="form-label visually-hidden">{{ t('views.publications.form.title_label') }}</label>
                <input type="search" v-model="title_str" class="form-control" id="title" :placeholder="t('views.publications.form.title_label')">
              </div>
            </form>
    </div>
</template>

<script setup>
import { useFilterStore} from '~/store/filter'
import { onMounted, onUnmounted } from 'vue'
import { usePublicationTypesStore } from '~/store/publication_types'
import { storeToRefs } from 'pinia'
import { useDebounceFn } from '@vueuse/core'
const props = defineProps(['pendingImportedPosts'])
const {t, getLocale} = useI18n();

const publicationTypesStore = usePublicationTypesStore()
const { fetchPublicationTypes } = publicationTypesStore
const { publicationTypes, pendingPublicationTypes } = storeToRefs(publicationTypesStore)
await fetchPublicationTypes({lang: getLocale()});

const filterStore = useFilterStore();
const {$reset} = filterStore;
const {filters} = storeToRefs(filterStore);

const title_str = ref(filters.value.title);

// throttle input
const debouncedFn = useDebounceFn(() => {
  filters.value.title = title_str.value;
}, 500)


onUnmounted(() => {
  $reset();
  console.log(`the uncomponent is now mounted.`)
})

watch(
  title_str, 
  () => {
    debouncedFn();
  }
)
</script>

<style lang="scss" scoped>

</style>