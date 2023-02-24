<template>
    <div class="alert alert-warning" v-if="data.show" >
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

<script setup>
import {onUnmounted } from 'vue'
const {t, getLocale} = useI18n();
const props = defineProps(['url', 'interval'])
const pollInterval =    (props.interval ? props.interval * 1000 : 60000)
let pollingID = null;
const { data, pending, error, refresh } = await useFetch(props.url)


const message = computed(() => {
    return data.value[getLocale()]
})

pollingID = setInterval(() => {
        refresh();
    }, pollInterval);


onUnmounted(() => clearInterval(pollingID))

</script>

<style lang="scss" scoped>

</style>