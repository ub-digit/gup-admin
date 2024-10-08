<template>
  <div>
    <button v-if="isLoggedIn" @click="handeSignOut">Sign Out</button>
    <button v-else @click="handeSignIn">Sign in</button>

    {{ data }}
  </div>
</template>

<script setup lang="ts">
const { status, data, signIn, signOut } = useAuth();

const isLoggedIn = computed(() => status.value === "authenticated");

async function handeSignIn() {
  await signIn();
}

async function handeSignOut() {
  await signOut();
}
</script>
