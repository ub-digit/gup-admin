<template>
    <div>
        <ul class="list-inline">
          <li v-if="!props.post.attended" class="list-inline-item"><font-awesome-icon class="text-danger" icon="fa-solid fa-flag" /> {{ t('views.publications.form.needs_attention') }}</li>
          <li class="list-inline-item"><font-awesome-icon class="text-info d-none" icon="fa-solid fa-file-arrow-down" /> <strong>{{ t('views.publications.post.import_source') }} </strong> {{ props.post.source }}</li>
          <li v-if="props.post.created_at" class="list-inline-item"><font-awesome-icon class="text-warning d-none" icon="fa-solid fa-award" /> <strong>{{ t("views.publications.post.created") }}</strong> {{ getDate(props.post.created_at) }} {{t("views.publications.post.created_by")}} {{ props.post.version_created_by }}</li>
          <li v-if="props.post.version_updated_by" class="list-inline-item"><font-awesome-icon class="text-warning d-none" icon="fa-solid fa-award" /> <strong>{{ t("views.publications.post.updated") }}</strong> {{ getDate(props.post.updated_at) }} {{t("views.publications.post.updated_by")}} {{ props.post.version_updated_by }}</li>
        </ul>
    </div>
</template>

<script setup>
const {t} = useI18n();
const props = defineProps(['post'])

const getDate = date => {
  let temp_date = new Date(date);
  return temp_date.getFullYear() + "-" + ('0' + (temp_date.getMonth()+1)).slice(-2)  + "-" + ('0' + temp_date.getDate()).slice(-2) 
}

</script>

<style lang="scss" scoped>

</style>