<template>
  <div class="person-search">
    <div class="mb-3">
      <label for="name" class="form-label">Namn</label>
      <input
        type="search"
        class="form-control"
        id="name"
        placeholder="Sök efter författare"
        v-model="searchNameStr"
      />
    </div>

    <ul class="list-group list-group-flush">
      <li
        class="list-group-item d-flex justify-content-between align-items-start"
        v-for="author in suggestedAuthors"
      >
        <div class="ms-2 me-auto">
          {{ author.full_name }}
          <div class="small">{{ author.x_account }}</div>
          <div class="small">{{ author.department }}</div>
        </div>
        <button class="btn btn-light" @click="handleAuthorSelected(author)">
          Välj
        </button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { useDebounceFn } from "@vueuse/core";
const emit = defineEmits(["authorSelected"]);
const props = defineProps({
  person: {
    type: Object,
    required: true,
  },
});

const searchNameStr = ref("");
const suggestedAuthors = ref([]);

// Set initial value here to get the watch to trigger on first render
onMounted(() => {
  searchNameStr.value = props.person.full_name;
});

const debounceFn = useDebounceFn(() => {
  if (searchNameStr.value.length > 2) {
    fetchSuggestedAuthors(searchNameStr.value);
  } else {
    suggestedAuthors.value = [];
  }
}, 500);

function handleAuthorSelected(author) {
  emit("authorSelected", author);
}

const fetchSuggestedAuthors = async (name) => {
  const response = await fetch(
    `/api/persons/suggest?name=${encodeURIComponent(name)}`
  );
  const data = await response.json();
  suggestedAuthors.value = data;
};

watch(searchNameStr, () => {
  debounceFn();
});
</script>

<style lang="scss" scoped>
.person-search {
}
</style>
