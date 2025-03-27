<template>
  <div>
    <NuxtLink
      :to="{
        name: 'departments-id-show',
        query: $route.query,
        params: { id: post.id },
      }"
      class="list-group-item list-group-item-action"
    >
      <div class="d-flex w-100 justify-content-between">
        <h5 class="title mb-0">{{ post.name_sv }}</h5>
      </div>
      <p class="text-muted mb-2 small">ID: {{ post.id }}</p>
    </NuxtLink>
  </div>
</template>

<script lang="ts" setup>
const props = defineProps(["post"]);
const { t } = useI18n();
</script>

<style lang="scss" scoped>
.list-group-item {
  &.router-link-active {
    background: rgb(223, 222, 222);
  }
}
.small {
  font-size: 10px;
}
</style>
