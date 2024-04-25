<template>
  <div>
    <NuxtLink
      :to="{
        name: 'authors-id',
        query: $route.query,
        params: { id: author.id },
      }"
      class="list-group-item list-group-item-action"
    >
      <div class="d-flex w-100 justify-content-between">
        <h5 class="title mb-0">
          {{ authorPrimaryName.first_name }} {{ authorPrimaryName.last_name }}
        </h5>
        <small class="text-muted"
          >+{{ author.names.length - 1 }} ytterligare namnform(er)
        </small>
      </div>
      <p v-if="author.id" class="text-muted mb-2 small">ID: {{ author.id }}</p>
      <div class="d-flex w-100 justify-content-between">
        <span v-if="authorCurrentDepartment">{{
          authorCurrentDepartment.name
        }}</span>
        <span v-else> Saknar primär avdelning </span>
        <small class="text-muted"
          >+
          <span v-if="authorCurrentDepartment">{{
            author.departments.length - 1
          }}</span>
          <span v-else>{{ author.departments.length }}</span>
          ytterligare avdelningar</small
        >
      </div>
      <small> {{ author.year_of_birth }}</small>
    </NuxtLink>
  </div>
</template>

<script lang="ts" setup>
import type { Nameform } from "~/types/Author";
import type { Department } from "~/types/Author";

const props = defineProps(["author"]);
const { t } = useI18n();

const authorCurrentDepartment = computed(() => {
  return props.author?.departments?.find(
    (department: Department) => department.current === true
  );
});
const authorPrimaryName = computed(() => {
  const primaryAuthor = props.author.names.find(
    (nameForm: Nameform) => nameForm.primary === true
  );
  if (primaryAuthor) {
    return primaryAuthor;
  } else {
    return props.author.names[0];
  }
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
