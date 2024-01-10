<template>
  <div class="handle-author">
    <div v-if="authorSelected" id="select-departments">
      <!-- make this a component -->
      <div class="selected-author mb-3">
        <div class="d-flex justify-content-between">
          <div class="author-info">
            {{ authorSelected.full_name }},
            <span class="small">({{ authorSelected.x_account }})</span>
          </div>
          <button
            class="btn btn-light btn-sm"
            v-if="authorSelected"
            @click="handleClearAuthorSelected(null)"
          >
            Rensa
          </button>
        </div>

        <div class="selected-author-selected-departments">
          <span
            @click="handleDepartmentRemove(department)"
            v-for="department in authorSelected.departments"
            class="badge btn pill text-bg-dark me-2 mb-2"
            >{{ department.id }} - {{ department.name }}
            <font-awesome-icon icon="fa-solid fa-delete-left"
          /></span>
        </div>
      </div>
      <label for="departments" class="form-label">Sök institutioner</label>
      <input
        type="search"
        class="form-control mb-3"
        id="departments"
        placeholder="Sök efter institutioner"
        v-model="searchDepartmentStr"
      />

      <ul class="list-group list-group-flush">
        <li
          class="list-group-item d-flex justify-content-between align-items-start"
          v-for="department in suggestedDepartmentsFiltered"
        >
          <div class="ms-2 me-auto">
            {{ department.id }} - {{ department.name }}
          </div>
          <button
            class="btn btn-light"
            @click="handleDepartmentSelected(department)"
          >
            Lägg till +
          </button>
        </li>
      </ul>
    </div>

    <div v-else id="select-author">
      <!-- make this a component -->
      <div class="mb-3">
        <label for="name" class="form-label">Sök författare</label>
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

    <button @click="$emit('success', authorSelected)">emit</button>
  </div>
</template>

<script setup>
import { useDebounceFn } from "@vueuse/core";
const emit = defineEmits(["success"]);
const props = defineProps({
  sourceSelectedAuthor: {
    type: Object,
    required: true,
  },
});

const searchDepartmentStr = ref("");
const suggestedDepartments = ref([]);
const searchNameStr = ref("");
const suggestedAuthors = ref([]);
const authorSelected = ref(null);

// Set initial value here to get the watch to trigger on first render
onMounted(() => {
  if (props.sourceSelectedAuthor.isMatch) {
    authorSelected.value = props.sourceSelectedAuthor;
  }
  searchNameStr.value = props.sourceSelectedAuthor.full_name;
});

const debounceDepeartmentsFn = useDebounceFn(() => {
  if (searchDepartmentStr.value.length > 2) {
    fetchSuggestedDepartments(searchDepartmentStr.value);
  } else {
    suggestedDepartments.value = [];
  }
}, 500);

const debounceFn = useDebounceFn(() => {
  if (searchNameStr.value.length > 2) {
    fetchSuggestedAuthors(searchNameStr.value);
  } else {
    suggestedAuthors.value = [];
  }
}, 500);

function handleDepartmentRemove(department) {
  const index = authorSelected.value.departments.indexOf(department);
  if (index > -1) {
    authorSelected.value.departments.splice(index, 1);
  }
}

function handleAuthorSelected(author) {
  //emit("authorSelected", author);
  authorSelected.value = author;
}

function handleDepartmentSelected(department) {
  authorSelected.value.departments.push(department);
}

function handleClearAuthorSelected() {
  authorSelected.value = null;
  searchDepartmentStr.value = "";
}

// remove already selected departments from suggestions
const suggestedDepartmentsFiltered = computed(() => {
  return suggestedDepartments.value.filter((department) => {
    return !authorSelected.value.departments.some(
      (selectedDepartment) => selectedDepartment.id === department.id
    );
  });
});

const fetchSuggestedDepartments = async (name) => {
  const response = await fetch(
    `/api/departments/suggest?name=${encodeURIComponent(name)}`
  );
  const data = await response.json();
  suggestedDepartments.value = data;
};

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

watch(searchDepartmentStr, () => {
  debounceDepeartmentsFn();
});
</script>

<style lang="scss" scoped>
.person-search {
}
</style>
