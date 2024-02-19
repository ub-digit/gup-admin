<template>
  <li class="list-group-item">
    <div class="row align-items-center">
      <div class="col-9">
        <div>
          <a
            href="#"
            @click.prevent="$emit('handleClickedPerson', (author, index))"
          >
            {{ author.full_name }}
          </a>
          <span
            v-if="author?.isMatch"
            title="Matchad i GUP"
            class="text-success ms-2"
            ><font-awesome-icon icon="fa-solid fa-check"
          /></span>
        </div>
        <div class="author-departments">
          <span
            v-for="department in author.departments"
            class="badge text-bg-dark pill me-2 opacity-50"
            >{{ department.name }}
          </span>
        </div>
      </div>
      <div class="col-2 text-center">
        <button
          @click="$emit('handleRemovePerson', (author, index))"
          class="btn btn-sm btn-danger"
        >
          <font-awesome-icon icon="fa-solid fa-trash" />
        </button>
      </div>
      <div class="col-1">
        <div id="sort">
          <div>
            <!-- wrap in div for block display -->
            <button
              @click="$emit('handleMoveUp', (author, index))"
              class="btn btn-sm float-end"
            >
              <font-awesome-icon icon="fa-solid fa-chevron-up" />
            </button>
          </div>
          <div>
            <button
              @click="$emit('handleMoveDown', (author, index))"
              class="btn btn-sm float-end"
            >
              <font-awesome-icon icon="fa-solid fa-chevron-down" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </li>
</template>

<script lang="ts" setup>
import fontawesome from "~/plugins/fontawesome";
interface Props {
  author: Object;
  index: Number;
}
const props = defineProps<Props>();

const emit = defineEmits<{
  (e: "handleClickedPerson", author: Object, index: number): void;
  (e: "handleRemovePerson", author: Object, index: number): void;
  (e: "handleMoveUp", author: Object, index: number): void;
  (e: "handleMoveDown", author: Object, index: number): void;
}>();
</script>

<style lang="scss" scoped></style>
