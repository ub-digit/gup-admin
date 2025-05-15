<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li
          class="breadcrumb-item"
          :class="department?.id === $route.params.id ? 'active' : ''"
          v-for="(department, index) in hierarchyFull"
          :key="index"
        >
          <NuxtLink
            :to="{
              name: 'departments-id-show',
              query: $route.query,
              params: { id: department?.id },
            }"
          >
            {{ department.name_sv }}
          </NuxtLink>
        </li>
        <li
          class="breadcrumb-item"
          :class="department?.id === $route.params.id ? 'active' : ''"
          v-if="department"
          :key="department?.id"
        >
          {{ department.name_sv }}
        </li>
      </ol>
    </nav>
  </div>
</template>

<script setup lang="ts">
// add props called department
import type { Department } from "~/types/Department";
const props = defineProps({
  department: {
    type: Object as () => Department,
    required: true,
  },
});

const hierarchyFull = ref([] as Department[]);

if (props.department.hierarchy) {
  for (let i = 0; i < props.department.hierarchy.length; i++) {
    const id = props.department.hierarchy[i];
    const { data, error } = await useFetch(`/api/departments/${id}/`);
    if (error.value) {
      console.error("Error fetching department:", error.value);
    } else {
      hierarchyFull.value.push(data?.value?.success.data);
    }
  }
}
</script>

<style scoped></style>
