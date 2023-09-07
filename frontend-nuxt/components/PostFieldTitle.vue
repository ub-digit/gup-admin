<template>
  <div v-if="title_second" class="col-2"></div>
  <div class="col">
    <div class="post-title" :class="{ 'do-not-truncate': isExpanded_first }">
      <a
        v-if="props.url_first"
        :href="props.url_first"
        target="_blank"
        class="no-color"
      >
        <h2 class="mb-0">
          <span v-if="!isExpanded_first">{{
            title_truncated(props.title_first)
          }}</span
          ><span v-else>{{ props.title_first }}</span>
        </h2>
      </a>
      <span v-else>
        <h2 class="mb-0">
          <span v-if="!isExpanded_first">{{
            title_truncated(props.title_first)
          }}</span
          ><span v-else>{{ props.title_first }}</span>
        </h2>
      </span>

      <a
        href="javascript:void(0)"
        v-if="showToggle(props.title_first)"
        @click.prevent="isExpanded_first = !isExpanded_first"
        ><span v-if="isExpanded_first">- Visa mindre</span
        ><span v-else>+ Visa mer</span></a
      >
    </div>
  </div>
  <div v-if="title_second" class="col">
    <div class="post-title" :class="{ 'do-not-truncate': isExpanded_second }">
      <a
        v-if="props.url_second"
        :href="props.url_second"
        target="_blank"
        class="no-color"
      >
        <h2 class="mb-0">
          <span v-if="!isExpanded_second">{{
            title_truncated(props.title_second)
          }}</span
          ><span v-else>{{ props.title_second }}</span>
        </h2>
      </a>
      <span v-else>
        <h2 class="mb-0">
          <span v-if="!isExpanded_second">{{
            title_truncated(props.title_second)
          }}</span
          ><span v-else>{{ props.title_second }}</span>
        </h2>
      </span>

      <a
        href="javascript:void(0)"
        v-if="showToggle(props.title_second)"
        @click.prevent="isExpanded_second = !isExpanded_second"
        ><span v-if="isExpanded_second">- Visa mindre</span
        ><span v-else>+ Visa mer</span></a
      >
    </div>
  </div>
</template>

<script setup>
const props = defineProps([
  "title_first",
  "title_second",
  "url_first",
  "url_second",
]);
const maxLength = 130;
let isExpanded_first = ref(false);
let isExpanded_second = ref(false);
const showToggle = (title) => {
  if (title && title.length > maxLength) {
    return true;
  }
  return false;
};
const title_truncated = (title) => {
  let resStr = title.substring(0, maxLength);
  if (title > resStr) {
    resStr = resStr + "...";
  }
  return resStr;
};
</script>

<style lang="scss" scoped>
.post-title {
  .no-color {
    color: rgb(51, 51, 51);
  }
  &.do-not-truncate {
    height: auto;
  }
}
</style>
