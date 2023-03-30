<template>
    <div :class="props.columnSize">
        <div class="card">
            <div class="card-body d-flex align-items-center justify-content-center ">
                <font-awesome-icon  class="inline-block text-muted fa-10x" icon="fa-regular fa-file" />
            </div>
        </div>
    </div>
</template>

<script setup>
    const props = defineProps(['columnSize'])
</script>

<style lang="scss" scoped>

.card {
    min-height: 400px;
    background-color: rgb(236, 236, 236);
    border: dotted;
    border-radius: 5px;
}
.background-icon {
    width: 100px;
}

</style>