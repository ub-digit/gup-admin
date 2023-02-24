<template>
<div>
  <Head>
    <title>{{t('seo.application_title')}}</title>
    <Meta name="description" :content="t('seo.application_title')" />
  </Head>
    <div class="container-fluid">
      <div class="row">
        <div class="col-3">
          <div class="row">
            <h1 class="page-title">{{ t("views.home.title") }}</h1>
            <form @submit.prevent=void(0) id="filters">
              <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" id="needs_attention" v-model="filters.needs_attention">
                <label class="form-check-label" for="needs_attention">{{ t('views.home.form.needs_attention') }}</label>
              </div>

              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="scopus" v-model="filters.scopus">
                <label class="form-check-label" for="scopus">{{ t('views.home.form.scopus_title') }}</label>
              </div>

              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="wos" v-model="filters.wos">
                <label class="form-check-label" for="wos">{{ t('views.home.form.wos_title') }}</label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="manual" v-model="filters.manual">
                <label class="form-check-label" for="manual">{{ t('views.home.form.manual_title') }}</label>
              </div>

              <select class="form-select" v-model="filters.pubtype" :aria-label="t('views.home.form.pub_type_select_label')">
                <option value="" selected>{{ t('views.home.form.pub_type_select_label') }}</option>
                <option v-for="pubtype in pubtypes" :value="pubtype" :key="pubtype">
                  {{ t('pubtypes.' +  pubtype) }}
                </option>
              </select>

              <div class="mb-3">
                <label for="title" class="form-label visually-hidden">{{ t('views.home.form.title_label') }}</label>
                <input type="text" v-model="filters.title" class="form-control" id="title" :placeholder="t('views.home.form.title_label')">
              </div>
            </form>
          </div>
          <div id="result-list" class="row">
            <div class="col">
              <div class="list-group list-group-flush border-bottom">
                  <PostRow v-for="post in posts" :post="post" :refresh="$route.query" :key="post.gup_id"/>
              </div>
            </div>
          </div>
        </div>

        <div class="col">
          <NuxtPage/>
      </div>
    </div>
  </div>
</div>
</template>

<script setup>
import _ from "lodash";
const {t, getLocale} = useI18n();
const config = useRuntimeConfig();
const route = useRoute();
const router = useRouter();
const alertURL = ref("/api/alert?" + "lang=" + getLocale());

const getBoolean = (item) => {
  if (item === "false" || item === undefined) {
    return undefined;
  }
  return true;
}
const { data: pubtypes, pending: pending_pubtypes, error: error_pubtypes, refresh: refresh_pubtypes } = await useFetch("/api/pubtypes", {
});

const filters = reactive({
  needs_attention: getBoolean(route.query.needs_attention),
  scopus: getBoolean(route.query.scopus),
  wos: getBoolean(route.query.wos),
  manual: getBoolean(route.query.manual),
  pubtype: route.query.pubtype ? route.query.pubtype : "",
  title: route.query.title ? route.query.title : undefined
});

const filters_for_api = computed(() => {
  const deepClone = _.cloneDeep(filters);
  deepClone.lang = getLocale();
  return deepClone;
}); 

const { data: posts, pending: pending_posts, error, refresh } = await useFetch("/api/posts", {
  params: filters_for_api,
  onRequest({ request, options }) {
    paramsSerializer(options.params);
  }
});

watch(
  filters,
  () => {
    router.push({query: {...route.query, ...filters}})
  },
  { deep: true }    
);

// remove from query if length === 0 
watch(
  () => filters.title,
  (title) => {
    if ((filters.title != undefined) && (filters.title.length == 0)) {
      filters.title = undefined;
    }
  }
)





function paramsSerializer(params) {
  //https://github.com/unjs/ufo/issues/62
  if (!params) {
    return;
  }
  Object.entries(params).forEach(([key, val]) => {
    if (typeof val === "object" && Array.isArray(val) && val !== null) {
      params[key + "[]"] = val.map((v) => JSON.stringify(v));
      delete params[key];
    } 
  });
}
</script>

<style lang="scss">
</style>