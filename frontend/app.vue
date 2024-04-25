<template>
  <div>
    <AppHeader />
    <NuxtPage />
  </div>
</template>

<script setup>
useHead({
  htmlAttrs: {
    lang: "en",
  },
});
const { t } = useI18n();
</script>
