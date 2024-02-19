<template>
  <div v-if="error" class="row">
    <div class="col text-center">
      <h2 class="mb-2 text-danger">
        <font-awesome-icon icon="fa-solid fa-circle-exclamation" />
        {{ error.code }}
      </h2>
      <p>
        {{ error.message }}
      </p>
    </div>
  </div>
</template>

<script lang="ts" setup>
interface Props {
  error: {
    code: number;
    message: string;
  };
}

const props = defineProps<Props>();
</script>

<style lang="scss" scoped></style>
