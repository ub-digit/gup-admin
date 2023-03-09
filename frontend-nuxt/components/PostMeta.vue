<template>
    <div>
        <ul class="list-inline">
          <li class="list-inline-item"><font-awesome-icon class="text-danger" icon="fa-solid fa-flag" /> {{ t('views.publications.form.needs_attention') }}</li>
          <li class="list-inline-item"><font-awesome-icon class="text-info" icon="fa-solid fa-file-arrow-down" /> {{ t('views.publications.post.import_from_scopus') }}</li>
          <li class="list-inline-item"><font-awesome-icon class="text-warning" icon="fa-solid fa-award" /> {{ props.post.date }} {{ t("views.publications.post.by") }} {{ props.post.creator }}</li>
        </ul>
    </div>
</template>

<script setup>
const {t} = useI18n();
const props = defineProps(['post'])

</script>

<style lang="scss" scoped>

</style>