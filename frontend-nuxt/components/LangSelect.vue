<template>
    <div>
      <div class="locale-toggler">
        <!-- https://github.com/FortAwesome/vue-fontawesome/issues/384
         extra wrapping span see above -->
        <button class="btn nav-link" id="navbarLanguageToggle" @click.prevent="setLocale(props.locale)">  <span><font-awesome-icon icon="fa-solid fa-globe" /></span> <slot/>
        </button>
      </div>
    </div>
  </template>
  
  <script setup>
    const props = defineProps(['locale'])
    const i18n = useI18n()
    const route = useRoute()
    const setLocale = async (locale) => {
      const router = useRouter()
      const route = useRoute()
      const newLocale = i18n.setLocale(locale)
      let query = {
        ...route.query,
        lang: newLocale
      }
      router.push({query})
    }
  </script>
  
  <style lang="scss" scoped>
  .locale-toggler {
    margin-top:10px;
  }
  </style>