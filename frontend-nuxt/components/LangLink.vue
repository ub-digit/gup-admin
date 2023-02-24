<template>
    <NuxtLink :to="linkRoute"><slot/></NuxtLink>
  </template>
  
  <script setup>
    const props = defineProps(['to', 'locale'])
    let link = useLink({to: props.to})
    
    let linkRoute = ref(null)
    watchEffect(async () => {
      const i18n = useI18n()
      const router = useRouter()
      const query = {
        ...link.route.value.query,
        lang: i18n.getLocale()
      }
      link.route.value.query = query
      linkRoute.value = router.resolve(link.route.value)
    })
  </script>
  