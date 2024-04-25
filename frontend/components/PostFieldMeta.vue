<template>
  <slot name="label"></slot>
  <div class="col">
    <slot name="content_first"></slot>
  </div>

  <slot name="content_second"></slot>
</template>

<script setup></script>

<style lang="scss" scoped>
.label {
  font-weight: bold;
}
</style>
