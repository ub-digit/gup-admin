<template>
  <div class="alert alert-warning" v-if="data.show">
    <div class="row">
      <div class="col-auto">
        <font-awesome-icon icon="circle-info" />
      </div>
      <div class="col">
        <span v-html="message"></span>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { onUnmounted } from "vue";
const { t, getLocale } = useI18n();

interface Props {
  url: string;
  interval: number;
}
const props = defineProps<Props>();

const pollInterval = props.interval ? props.interval * 1000 : 60000;
const { data, pending, error, refresh } = await useFetch(props.url);

const message = computed(() => {
  return data.value[getLocale()];
});

let pollingID: ReturnType<typeof setInterval> = setInterval(() => {
  refresh();
}, pollInterval);

onUnmounted(() => clearInterval(pollingID));
</script>

<style lang="scss" scoped></style>
