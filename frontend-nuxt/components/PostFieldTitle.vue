<template>
  <div v-if="title_second" class="col-2"></div>
  <!-- extra div for spacing -->
  <div class="col">
    <div class="post-title">
      <a
        v-if="props.url_first"
        :href="props.url_first"
        target="_blank"
        class="no-color"
      >
        <h2 class="mb-0">
          <span v-html="props.title_first"></span>
        </h2>
      </a>
      <span v-else>
        <h2 class="mb-0">
          <span v-html="props.title_first"></span>
        </h2>
      </span>
    </div>
  </div>
  <div v-if="title_second" class="col">
    <div class="post-title">
      <a
        v-if="props.url_second"
        :href="props.url_second"
        target="_blank"
        class="no-color"
      >
        <h2 class="mb-0">
          <span v-html="props.title_second"></span>
        </h2>
      </a>
      <span v-else>
        <h2 class="mb-0">
          <span v-html="props.title_second"></span>
        </h2>
      </span>
    </div>
  </div>
</template>

<script lang="ts" setup>
const props = defineProps([
  "title_first",
  "title_second",
  "url_first",
  "url_second",
]);
const maxLength = 130;
let isExpanded_first = ref(false);
let isExpanded_second = ref(false);
const showToggle = (title: string) => {
  if (title && title.length > maxLength) {
    return true;
  }
  return false;
};
const title_truncated = (title: string) => {
  let resStr = title.substring(0, maxLength);
  if (title > resStr) {
    resStr = resStr + "...";
  }
  return resStr;
};
</script>

<style lang="scss" scoped>
.post-title {
  overflow-y: scroll;
  resize: vertical;
  height: 112px;
  .no-color {
    color: rgb(51, 51, 51);
  }
  &.do-not-truncate {
    height: auto;
  }
}
</style>
