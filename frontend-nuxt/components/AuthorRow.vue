<template>
  <li class="list-group-item">
    <div class="row align-items-center">
      <div class="col-9">
        <div>
          <a
            href="#"
            @click.prevent="$emit('handleClickedPerson', (author, index))"
          >
            {{ authorPrimary?.first_name }} {{ authorPrimary?.last_name
            }}<span v-if="authorPrimary?.primary">*</span>
          </a>
          <span class="small" v-if="author.names.length > 1">
            + {{ author.names.length - 1 }} fler namnformer</span
          >
          <!-- <span
            v-if="author?.isMatch"
            title="Matchad i GUP"
            class="text-success ms-2"
            ><font-awesome-icon icon="fa-solid fa-check"
          /></span> -->
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
import type { Author, Nameform } from "~/types/Author";
interface Props {
  author: Author;
  index: Number;
}
const props = defineProps<Props>();

const authorPrimary = computed(() => {
  return props.author.names.find((nameform: Nameform) => {
    return nameform.primary;
  });
});

const emit = defineEmits<{
  (e: "handleClickedPerson", author: Object, index: number): void;
  (e: "handleRemovePerson", author: Object, index: number): void;
  (e: "handleMoveUp", author: Object, index: number): void;
  (e: "handleMoveDown", author: Object, index: number): void;
}>();
</script>

<style lang="scss" scoped></style>
