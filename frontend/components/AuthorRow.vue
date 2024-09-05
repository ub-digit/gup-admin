<template>
  <li class="list-group-item">
    <div class="row align-items-center">
      <div class="col-9">
        <div>
          <a
            href="#"
            @click.prevent="$emit('handleClickedPerson', (author, index))"
          >
            {{ author.name }}
          </a>
        </div>
        <div>
          {{ author.affiliation_str }}
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
import type { AuthorAffiliation } from "~/types/Publication";
interface Props {
  author: AuthorAffiliation;
  index: Number;
}
const props = defineProps<Props>();

/*const authorPrimary = computed(() => {
  const temp = props.author.names.find((nameform: Nameform) => {
    return nameform.primary;
  });
  if (temp) {
    return temp;
  } else {
    return props.author.names[0];
  }
});*/

const emit = defineEmits<{
  (e: "handleClickedPerson", author: AuthorAffiliation, index: number): void;
  (e: "handleRemovePerson", author: AuthorAffiliation, index: number): void;
  (e: "handleMoveUp", author: AuthorAffiliation, index: number): void;
  (e: "handleMoveDown", author: AuthorAffiliation, index: number): void;
}>();
</script>

<style lang="scss" scoped></style>
