<template>
  <div>
    <AppHeader />
    <NuxtPage />
    <AppFooter/>
  </div>
</template>

<script setup>
  useHead({
    htmlAttrs: {
      lang: 'en'
    }
  })
  const { t } = useI18n()
</script>