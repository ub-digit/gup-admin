<template>
    <div>
        <div class="post-title p-2 mb-4" :class="{'do-not-truncate' : isExpanded }">
            <a v-if="props.url" :href="props.url" target="_blank" class="no-color">
                <h2 class="pb-2 mb-0"><span v-if="!isExpanded">{{ post_title_truncated }}</span><span v-else>{{ props.title }}</span></h2> 
            </a>
            <span v-else>
                <h2 class="pb-2 mb-0"><span v-if="!isExpanded">{{ post_title_truncated }}</span><span v-else>{{ props.title }}</span></h2> 
            </span>
                

            <a href="javascript:void(0)" v-if="showToggle" @click.prevent="isExpanded = !isExpanded"><span v-if="isExpanded">- Visa mindre</span><span v-else>+ Visa mer</span></a>
        </div>
    </div>
</template>

<script setup>
const props = defineProps(['title', 'url'])
const maxLength = 85;
let isExpanded = ref(false);
const showToggle = computed(()=> {
    if (props.title && (props.title.length > maxLength)) {
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
    .no-color {
        color: rgb(51, 51,51);
    }
    min-height: 11em;
    &.do-not-truncate {
        height: auto;
    }   
}
</style>