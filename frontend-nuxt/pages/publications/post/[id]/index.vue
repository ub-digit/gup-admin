<template>
  <NothingSelected />
</template>

<script setup>
import { useGupPostsStore } from "~/store/gup_posts";
import { storeToRefs } from "pinia";
const gupPostsStore = useGupPostsStore();
const { $reset } = gupPostsStore;
$reset();
</script>
