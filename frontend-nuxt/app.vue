<template>
  <div>
    <!-- <NuxtLoadingIndicator color="#025da6" />  -->
    <AppHeader />
    <NuxtPage />
<!--     <AppFooter/> -->
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