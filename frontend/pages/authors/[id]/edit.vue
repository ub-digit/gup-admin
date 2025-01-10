<template>
  <h2>Redigera person</h2>
  <form v-if="author">
    <h3>Namnfomer</h3>
    <div
      style="border: 1px solid #ccc; border-radius: 4px"
      class="mb-3 p-3"
      v-for="name in author.names"
    >
      <div class="row">
        <div class="mb-3 col">
          <label :for="`first_name_${name.gup_person_id}`" class="form-label"
            >Förnamn</label
          >
          <input
            type="text"
            class="form-control"
            :id="`first_name_${name.gup_person_id}`"
            v-model="name.first_name"
          />
        </div>
        <div class="mb-3 col">
          <label :for="`last_name_${name.gup_person_id}`" class="form-label"
            >Efternamn</label
          >
          <input
            type="text"
            class="form-control"
            :id="`last_name_${name.gup_person_id}`"
            v-model="name.last_name"
          />
        </div>
      </div>
      <div class="mb-3">
        <div class="form-check">
          <input
            class="form-check-input"
            type="radio"
            :checked="name.primary"
            @change="setPrimaryName(name.gup_person_id)"
            :id="`is_primary_name_${name.gup_person_id}`"
          />
          <label
            class="form-check-label"
            :for="`is_primary_name_${name.gup_person_id}`"
          >
            Primär namnform
          </label>
        </div>
      </div>
    </div>
    <div class="mb-3">
      <label for="year_of_birth" class="form-label">Födelseår</label>
      <input type="text" class="form-control" v-model="author.year_of_birth" />
    </div>

    <div class="mb-3">
      <h3>Identifikatorer</h3>
      <div style="border: 1px solid #ccc; border-radius: 4px" class="p-3">
        <div class="mb-3" v-for="(identifier, index) in author.identifiers">
          <div class="row">
            <div class="col">
              <select
                :id="`identifier_code_${index}`"
                class="form-select"
                v-model="identifier.code"
                aria-label=""
              >
                <option disabled value="">Välj identfierare</option>

                <option
                  v-for="identifier in identifiers"
                  :value="identifier.code"
                >
                  {{ identifier.code }}
                </option>
              </select>
            </div>
            <div class="col">
              <input
                :id="`identifier_value_${index}`"
                type="text"
                class="form-control"
                v-model="identifier.value"
              />
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
    <NuxtLink
      class="btn btn-danger me-2"
      :to="{
        name: 'authors-id',
        query: $route.query,
        params: { id: author.id },
      }"
    >
      Avbryt
    </NuxtLink>
    <button type="button" class="btn btn-success" @click.prevent="saveAuthor()">
      Spara
    </button>
  </form>

  <div class="row mt-5">
    <div class="col">
      <h3>Submitted data (debug)</h3>
      <pre>{{ submittedData }}</pre>
    </div>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import type { Nameform } from "~/types/Author";
import { useAuthorsStore } from "~/store/authors";
import _ from "lodash";

const route = useRoute();
const storeAuthor = useAuthorsStore();
const { author, identifiers } = storeToRefs(storeAuthor);
const { getAuthorById, fetchIdentifiers, updateAuthor } = storeAuthor;
const submittedData = ref({});

await getAuthorById(route.params.id as string);
await fetchIdentifiers();

//const authorClone = _.cloneDeep(author);

function addIdentifierItem() {
  author?.value?.identifiers.push({ code: "", value: "" });
}

const saveAuthor = async () => {
  submittedData.value = await updateAuthor(
    route.params.id as string,
    author?.value
  );
};

function setPrimaryName(gup_person_id: number) {
  author?.value?.names.forEach((name: Nameform) => {
    if (name.gup_person_id === gup_person_id) {
      name.primary = true;
    } else {
      name.primary = false;
    }
  });
}
</script>

<style scoped></style>
