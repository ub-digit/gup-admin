<template>
  <div>
    <div v-if="errors.length" class="alert alert-danger">
      <ul>
        <li v-for="error in errors" :key="error">
          {{ t(`views.authors.edit.form.errors.${error}`) }}
        </li>
      </ul>
    </div>
    <form v-if="authorReactive">
      <h3>Namnfomer</h3>
      <div class="mb-3 p-3" style="border: 1px solid #ccc; border-radius: 4px">
        <div class="" v-for="(name, index) in authorReactive.names">
          <div class="row">
            <div class="mb-3 col">
              <label :for="`first_name_${index}`" class="form-label"
                >Förnamn</label
              >
              <input
                type="text"
                class="form-control"
                :id="`first_name_${index}`"
                v-model="name.first_name"
              />
            </div>
            <div class="mb-3 col">
              <label :for="`last_name_${index}`" class="form-label"
                >Efternamn</label
              >
              <input
                type="text"
                class="form-control"
                :id="`last_name_${index}`"
                v-model="name.last_name"
              />
            </div>
            <div class="col-2 mb-3 d-flex align-items-center">
              <div class="form-check mt-4">
                <input
                  class="form-check-input"
                  type="radio"
                  :checked="name.primary"
                  @change="setPrimaryName(index as number)"
                  :id="`is_primary_name_${index}`"
                />
                <label
                  class="form-check-label"
                  :for="`is_primary_name_${index}`"
                >
                  Primär
                </label>
              </div>
            </div>
            <div class="col-2 mb-3 d-flex align-items-center">
              <button
                :disabled="name?.gup_person_id ? true : false"
                class="btn btn-danger mt-4"
                @click.prevent="authorReactive.names.splice(index, 1)"
              >
                Ta bort
              </button>
            </div>
          </div>
        </div>
        <button class="btn btn-primary" @click.prevent="addNameformItem()">
          Lägg till namnform
        </button>
      </div>
      <div class="mb-3">
        <div class="row">
          <div class="col-3">
            <label for="year_of_birth" class="form-label">Födelseår</label>
            <input
              type="number"
              class="form-control"
              v-model="authorReactive.year_of_birth"
            />
          </div>
        </div>
      </div>

      <div class="mb-3">
        <h3>Identifikatorer</h3>
        <div style="border: 1px solid #ccc; border-radius: 4px" class="p-3">
          <div
            class="mb-3"
            v-for="(identifier, index) in authorReactive.identifiers"
          >
            <div class="row">
              <div class="col">
                <span v-if="identifier.value">
                  {{ t(`views.authors.identifier_type.${identifier.code}`) }}
                </span>
                <select
                  :id="`identifier_code_${index}`"
                  class="form-select"
                  v-model="identifier.code"
                  aria-label=""
                  v-else
                >
                  <option disabled value="">Välj identfierare</option>

                  <option
                    v-for="identifier in identifiers"
                    :value="identifier.code"
                  >
                    {{ t(`views.authors.identifier_type.${identifier.code}`) }}
                  </option>
                </select>
              </div>
              <div class="col">
                <input
                  :disabled="
                    dissallowedToEditIdentifiers.includes(identifier.code)
                  "
                  :id="`identifier_value_${index}`"
                  type="text"
                  class="form-control"
                  v-model="identifier.value"
                />
              </div>
              <div class="col-2">
                <button
                  :disabled="
                    dissallowedToEditIdentifiers.includes(identifier.code)
                  "
                  class="btn btn-danger"
                  @click.prevent="authorReactive.identifiers.splice(index, 1)"
                >
                  Ta bort
                </button>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col">
              <button
                class="btn btn-primary"
                @click.prevent="addIdentifierItem()"
              >
                Lägg till identifikator
              </button>
            </div>
          </div>
        </div>
      </div>
      <button class="btn btn-danger me-2" @click.prevent="$emit('onCancel')">
        Avbryt
      </button>
      <button
        type="button"
        class="btn btn-success"
        @click.prevent="saveAuthor()"
      >
        {{ submitBtnText }}
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import type { Author, Nameform } from "~/types/Author";
import { useAuthorsStore } from "~/store/authors";
const { t, getLocale } = useI18n();
const storeAuthor = useAuthorsStore();
const { identifiers } = storeToRefs(storeAuthor);
const { fetchIdentifiers } = storeAuthor;
const config = useRuntimeConfig();

const dissallowedToEditIdentifiers = computed(() =>
  config?.public?.DISALLOW_EDIT_PERSON_IDENTIFICATION_CODES.split(",")
);

interface Props {
  author: Author;
  submitBtnText?: string;
  errors: string[];
}
const { author, submitBtnText = "Spara" } = defineProps<Props>(); // default is set for submitBtnText only
const emit = defineEmits(["submit", "onCancel"]); // handle these events in your parent component

// make a ref object to use in the form
const authorReactive: Ref<Author> = ref(author);

await fetchIdentifiers();

function saveAuthor() {
  emit("submit", authorReactive.value);
}

function addIdentifierItem() {
  authorReactive?.value?.identifiers.push({ code: "", value: null });
}
function addNameformItem() {
  authorReactive?.value?.names.push({
    first_name: "",
    last_name: "",
    primary: false,
  });
}

function setPrimaryName(index: number) {
  authorReactive?.value?.names.forEach((name: Nameform, index_local) => {
    if (index_local === index) {
      name.primary = true;
    } else {
      name.primary = false;
    }
  });
}
</script>

<style scoped></style>
