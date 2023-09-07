<template>
  <div>
    <NuxtLink
      :to="{
        name: 'publications-post-id-gup-gupid',
        query: $route.query,
        params: { id: post.id, gupid: 'empty' },
      }"
      class="list-group-item list-group-item-action"
    >
      <div class="d-flex w-100 justify-content-between">
        <h5 class="title mb-0">{{ post_title_truncated }}</h5>
      </div>
      <p v-if="post.id" class="text-muted d-none mb-2 small">
        ID: {{ post.id }}
      </p>
      <p class="mb-0">{{ post.pubyear }}</p>
      <small> {{ post.publication_type_label }}</small>
    </NuxtLink>
  </div>
</template>

<script setup>
const props = defineProps(["post"]);
const { t } = useI18n();
const maxLength = 85;

const post_title_truncated = computed(() => {
  let resStr = props.post.title.substring(0, maxLength);
  if (props.post.title > resStr) {
    resStr = resStr + "...";
  }
  return resStr;
});

const numerOfAuthors = computed(() => {
  return props.post.authors ? props.post.authors.length : 0;
});
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
