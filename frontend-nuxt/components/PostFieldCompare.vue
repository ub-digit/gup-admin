<template>
    <div class="row mb-2">
        <div class="col-2 fw-bold">
            <slot name="label">
            </slot>
        </div>
        <div class="col-5">
            <slot name="content_imported"></slot>
        </div>
        <div class="col-5">
            <slot name="content_gup"></slot>
        </div>
    </div>
</template>

<script setup>

</script>

<style lang="scss" scoped>

</style>