<template>
  <li class="list-group-item">
    <div class="row">
      <div class="col-10">
        <div>
          <a
            href="#"
            @click.prevent="$emit('handleClickedPerson', (author, index))"
          >
            {{ author.full_name }}
          </a>
        </div>
        <div class="author-departments">
          <span
            v-for="department in author.departments"
            class="badge text-bg-dark pill me-2 opacity-50"
            >{{ department.id }} - {{ department.name }}
          </span>
        </div>
      </div>
      <div class="col">
        <div id="sort">
          <div>
            <!-- wrap in div for block display -->
            <button
              @click="$emit('handleMoveUp', author, index)"
              class="btn btn-sm"
            >
              <font-awesome-icon icon="fa-solid fa-chevron-up" />
            </button>
          </div>
          <div>
            <button
              @click="$emit('handleMoveDown', author, index)"
              class="btn btn-sm"
            >
              <font-awesome-icon icon="fa-solid fa-chevron-down" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </li>
</template>

<script setup>
const props = defineProps({ author: Object, index: Number });
const emit = defineEmits([
  "handleClickedPerson",
  "handleMoveUp",
  "handleMoveDown",
]);
</script>

<style lang="scss" scoped></style>
