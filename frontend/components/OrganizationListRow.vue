<template>
  <div>
    <NuxtLink
      :to="{
        name: 'organizations-id',
        query: $route.query,
        params: { id: organization.id },
      }"
      class="list-group-item list-group-item-action"
    >
      <div class="d-flex w-100 justify-content-between">
        <h5 class="title mb-0">
          {{ organization.name_sv }}
        </h5>
      </div>
      <p v-if="organization.id" class="text-muted mb-2 small">
        ID: {{ organization.id }}
      </p>
    </NuxtLink>
  </div>
</template>

<script lang="ts" setup>
import type { Nameform } from "~/types/Author";
import type { Department } from "~/types/Author";

const props = defineProps(["organization"]);
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
