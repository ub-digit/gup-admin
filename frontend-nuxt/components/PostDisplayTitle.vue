<template>
    <div>
        <div class="post-title p-2 mb-4" :class="{'do-not-truncate' : isExpanded }">
            <h2 class="pb-2 mb-0"><span v-if="!isExpanded">{{ post_title_truncated }}</span><span v-else>{{ props.title }}</span></h2> 
            <a href="javascript:void(0)" v-if="showToggle" @click.prevent="isExpanded = !isExpanded"><span v-if="isExpanded">- Visa mindre</span><span v-else>+ Visa mer</span></a>
        </div>
    </div>
</template>

<script setup>
const props = defineProps(['title'])
const maxLength = 85;
let isExpanded = ref(false);
const showToggle = computed(()=> {
    if (props.title.length > maxLength) {
        return true;
    }
    return false;
})
const post_title_truncated = computed(() => {
  let resStr = props.title.substring(0, maxLength);
  if ( props.title > resStr) {
    resStr = resStr + "...";
  }
  return resStr;
})
</script>

<style lang="scss" scoped>
.post-title {
    min-height: 11em;
    &.do-not-truncate {
        height: auto;
    }   
}
</style>