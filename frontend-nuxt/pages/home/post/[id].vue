<template>
    <div>
        this is a post with id {{ $route.params.id }}
        <h3>Icons</h3>
          <ul class="list-style">
            <li><font-awesome-icon class="text-danger" icon="fa-solid fa-flag" /></li>
            <li><font-awesome-icon class="text-info" icon="fa-solid fa-file-arrow-down" /></li>
            <li><font-awesome-icon class="text-warning" icon="fa-solid fa-award" /></li>
          </ul>
          <h3>Buttons/Links</h3>
          <LangLink class="btn btn-danger" to="/">{{t('buttons.remove')}}</LangLink>
          <LangLink class="btn btn-secondary" to="/">{{t('buttons.merge')}}</LangLink>
          <LangLink class="btn btn-success" to="/">{{t('buttons.edit')}}</LangLink>
    </div>
</template>

<script setup>
const {t} = useI18n();
const route = useRoute();

const { data: post, pending: pending, error, refresh } = await useFetch(`/api/post/${route.params.id}`);


</script>

<style lang="scss" scoped>

</style>