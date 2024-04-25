<template>
  <NuxtLink :to="linkRoute"><slot /></NuxtLink>
</template>

<script setup>
const props = defineProps(["to", "locale"]);
let linkRoute = ref(null);
let link = useLink({ to: props.to });
watchEffect(async () => {
  const i18n = useI18n();
  const router = useRouter();
  const query = {
    ...link.route.value.query,
    lang: i18n.getLocale(),
  };
  link.route.value.query = query;
  linkRoute.value = router.resolve(link.route.value);
});
</script>
