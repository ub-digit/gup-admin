<template>
  <div class="container">
    <main class="form-signin w-25 m-auto">
      <a href="javascript:void(0)" @click="handeSignIn">
        <div class="card">
          <div class="card-body">
            <img
              class="w-75 pb-2"
              src="/gu-logo-login-gu-account@2x-8a8e76fad488c11b78fa089d140b3995.png"
              alt="gu-logo"
            />
            <h4 class="card-title">Logga in med Github</h4>
            <p>För anställda vid GU med ett x-konto.</p>
          </div>
        </div>
      </a>

      <div v-if="hasError" class="alert alert-danger mt-3" role="alert">
        <div>Någon gick fel vid inloggningen. Försök igen.</div>
        <div>code: {{ hasError }}</div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  auth: { unauthenticatedOnly: true, navigateAuthenticatedTo: "/" },
});
const { status, data, signIn, signOut } = useAuth();
const isLoggedIn = computed(() => status.value === "authenticated");
const route = useRoute();

const hasError = computed(() => route.query.error);

async function handeSignIn() {
  await signIn("github");
}

async function handeSignOut() {
  await signOut("github");
}
</script>
