<script lang="ts" setup>
import { useDebounceFn } from "@vueuse/core";
import type { Ref } from "vue";
import { ref } from "vue";
import type { Author, Department } from "~/types/Author";
import { zAuthorResultList, zDepartmentArray } from "~/types/Author";
const emit = defineEmits(["success", "close"]);
const props = defineProps({
  sourceSelectedAuthor: {
    type: Object as () => Author | null,
    required: true,
  },
  publicationYear: {
    type: String as () => string | null,
    required: true,
  },
});

const searchDepartmentStr = ref("");
const suggestedDepartments: Ref<Department[]> = ref([]);
const searchNameStr = ref("");
const suggestedAuthors: Ref<Author[]> = ref([]);
const authorSelected: Ref<Author | null> = ref(null);
const searchDepartmentsInput = ref("");
const searchAuthorsInput = ref("");

// Set initial value here to get the watch to trigger on first render
onMounted(() => {
  if (props?.sourceSelectedAuthor?.isMatch) {
    authorSelected.value = props.sourceSelectedAuthor;
  }
  searchNameStr.value =
    primaryAuthorName?.value?.first_name +
    " " +
    primaryAuthorName?.value?.last_name;
  focusInput(searchAuthorsInput);
});

const primaryAuthorName = computed(() => {
  const temp = props.sourceSelectedAuthor?.names.find((name) => name.primary);
  if (temp) {
    return temp;
  } else {
    return props.sourceSelectedAuthor?.names[0];
  }
});

const primaryAuthorNameSelected = computed(() => {
  const temp = authorSelected?.value?.names.find((name) => name.primary);
  if (temp) {
    return temp;
  } else {
    return authorSelected?.value?.names[0];
  }
});

const debounceDepartmentsFn = useDebounceFn(() => {
  if (searchDepartmentStr.value.length > 2) {
    fetchSuggestedDepartments(searchDepartmentStr.value, props.publicationYear);
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

function handleDepartmentRemove(department: Department) {
  if (authorSelected.value) {
    const index = authorSelected.value.departments.indexOf(department);
    if (index > -1) {
      authorSelected.value.departments.splice(index, 1);
    }
  }
  focusInput(searchDepartmentsInput);
}

function handleAuthorSelected(author: Author) {
  //emit("authorSelected", author);
  authorSelected.value = author;
}

function handleDepartmentSelected(department: Department) {
  if (authorSelected.value) {
    authorSelected.value.departments.push(department);
  }
  focusInput(searchDepartmentsInput);
}

function handleClearAuthorSelected() {
  authorSelected.value = null;
  searchDepartmentStr.value = "";
}

const getPrimaryName = (author: Author) => {
  return author.names.find((name) => name.primary === true);
};

// remove already selected departments from suggestions
const suggestedDepartmentsFiltered = computed(() => {
  return suggestedDepartments.value.filter((department) => {
    if (!authorSelected.value) return true;
    return !authorSelected.value.departments.some(
      (selectedDepartment) => selectedDepartment.id === department.id
    );
  });
});

const fetchSuggestedDepartments = async (
  name: string,
  year?: number | null
) => {
  const { data, error } = await useFetch("/api/departments/suggest", {
    params: { name: name, year: year },
  });

  suggestedDepartments.value = zDepartmentArray.parse(data.value);
  console.log(suggestedDepartments.value);
};

const fetchSuggestedAuthors = async (name: string) => {
  const { data, error } = await useFetch("/api/author/suggest", {
    params: { query: name },
  });
  //const response = await fetch(`/api/author/suggest?query=${name}`);
  suggestedAuthors.value = zAuthorResultList.parse(data.value).data;
};

watch(authorSelected, async () => {
  await nextTick();
  if (authorSelected.value) {
    focusInput(searchDepartmentsInput);
  } else {
    focusInput(searchAuthorsInput);
  }
});

watch(searchNameStr, () => {
  debounceFn();
});

watch(searchDepartmentStr, () => {
  debounceDepartmentsFn();
});

const focusInput = (val) => {
  if (val.value) {
    val.value.focus();
  }
};
</script>

<template>
  <Transition name="modal">
    <div class="modal-mask modal">
      <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <div class="modal-title">
              <h4 class="mb-0">Hantera författare</h4>
            </div>
          </div>

          <div class="modal-body">
            <div class="handle-author">
              <div v-if="authorSelected" id="select-departments">
                <!-- make this a component -->
                <div class="selected-author mb-3">
                  <div
                    class="d-flex justify-content-between align-items-center"
                  >
                    <div class="author-info">
                      {{ primaryAuthorNameSelected?.full_name }}
                      <div class="small">
                        {{ authorSelected.year_of_birth }}
                      </div>
                      <div class="small">
                        <ul class="list-inline">
                          <li
                            class="list-inline-item small text-muted"
                            v-for="(
                              identifier, index
                            ) in authorSelected?.identifiers"
                          >
                            {{ identifier.value }}
                            <span
                              v-if="
                                index < authorSelected.identifiers.length - 1
                              "
                            >
                              |
                            </span>
                          </li>
                        </ul>
                      </div>
                    </div>
                    <button
                      class="btn btn-light btn-sm"
                      v-if="authorSelected"
                      @click="handleClearAuthorSelected()"
                    >
                      Rensa
                    </button>
                  </div>

                  <div class="selected-author-selected-departments">
                    <span
                      @click="handleDepartmentRemove(department)"
                      v-for="department in authorSelected.departments"
                      class="badge btn pill text-bg-dark me-2 mb-2"
                      >{{ department.name }}
                      <font-awesome-icon icon="fa-solid fa-delete-left"
                    /></span>
                  </div>
                </div>
                <label for="departments" class="form-label"
                  >Sök institutioner</label
                >
                <input
                  ref="searchDepartmentsInput"
                  type="search"
                  class="form-control mb-3"
                  id="departments"
                  placeholder="Sök efter institutioner"
                  v-model="searchDepartmentStr"
                />
                <ul
                  v-if="suggestedDepartments.length"
                  class="list-group list-group-flush"
                >
                  <li
                    class="list-group-item d-flex justify-content-between align-items-center"
                    v-for="department in suggestedDepartmentsFiltered"
                  >
                    <div class="ms-2 me-4">
                      {{ department.name }}
                    </div>
                    <button
                      class="btn btn-light"
                      @click="handleDepartmentSelected(department)"
                    >
                      +
                    </button>
                  </li>
                </ul>
                <div v-else class="text-muted">Inga institutioner hittades</div>
              </div>

              <div v-else id="select-author">
                <!-- make this a component -->
                <div class="mb-3">
                  <label for="name" class="form-label">Sök författare</label>
                  <input
                    ref="searchAuthorsInput"
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
                    <div>
                      <div class="ms-2 me-auto">
                        {{ getPrimaryName(author)?.full_name }} *
                      </div>
                      <div class="ms-2 me-auto">
                        {{ author?.email }}
                      </div>

                      <div class="ms-2 me-auto">
                        {{ author?.year_of_birth }}
                      </div>
                    </div>
                    <button
                      class="btn btn-light"
                      @click="handleAuthorSelected(author)"
                    >
                      Välj
                    </button>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <slot name="footer">
              <button class="btn btn-secondary" @click="$emit('close')">
                Avbryt
              </button>
              <button
                class="btn btn-primary"
                @click="$emit('success', authorSelected)"
              >
                Spara
              </button>
            </slot>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style>
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  transition: opacity 0.3s ease;
}

@media (min-width: 768px) {
  .modal-dialog {
    width: 600px;
    margin: 30px auto;
  }
}

.modal-default-button {
  float: right;
}

/*
 * The following styles are auto-applied to elements with
 * transition="modal" when their visibility is toggled
 * by Vue.js.
 *
 * You can easily play with the modal transition by editing
 * these styles.
 */

.modal-enter-from {
  opacity: 0;
}

.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  -webkit-transform: scale(1.1);
  transform: scale(1.1);
}
</style>
