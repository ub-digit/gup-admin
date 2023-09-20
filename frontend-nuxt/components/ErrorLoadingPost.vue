<template>
  <div v-if="error" class="row">
    <div class="col text-center">
      <h2 class="mb-2 text-danger">
        <font-awesome-icon icon="fa-solid fa-circle-exclamation" />
        {{ error.statusCode }}
      </h2>
      <p>
        {{ error.statusMessage }}
      </p>
    </div>
  </div>
</template>

<script setup>
const props = defineProps(["error"]);
</script>

<style lang="scss" scoped></style>
