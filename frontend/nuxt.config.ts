import { BaseModuleDeclaration } from "./node_modules/@types/estree/index.d";
// https://nuxt.com/docs/api/configuration/nuxt-config

export default defineNuxtConfig({
  ssr: true,
  runtimeConfig: {
    API_BASE_URL: "http://localhost:40415/", // this should point to admin-backend
    GITHUB_CLIENT_ID: process.env.GITHUB_CLIENT_ID || "",
    GITHUB_CLIENT_SECRET: process.env.GITHUB_CLIENT_SECRET || "",
    GU_CLIENT_ID: process.env.GU_CLIENT_ID || "",
    GU_CLIENT_SECRET: process.env.GU_CLIENT_SECRET || "",
    AUTH_USERS: process.env.AUTH_USERS || "",
    authOrigin: "",
    authBaseUrl: "",
    public: {
      API_GUP_BASE_URL: "http://localhost:8181", // this should point to gup-frontend and is used to redirect to posts for show/edit in gup-frontend
      ALLOW_AUTHOR_EDIT: true,
    },
    /*         server: {
          host: process.env.NUXT_HOST,
          port: process.env.NUXT_PORT,
        },   */
  },

  typescript: {
    shim: false,
    strict: true,
  },
  modules: ["@pinia/nuxt", "@vueuse/nuxt", "@sidebase/nuxt-auth"],

  auth: {
    provider: {
      type: "authjs",
    },
    globalAppMiddleware: true,
    originEnvKey: "NUXT_AUTH_ORIGIN",
    baseURL: process.env.authBaseUrl,
  },
  build: {
    transpile: [
      "@fortawesome/fontawesome-svg-core",
      "@fortawesome/free-brands-svg-icons",
      "@fortawesome/free-regular-svg-icons",
      "@fortawesome/free-solid-svg-icons",
      "@fortawesome/vue-fontawesome",
    ],
  },
  css: [
    // SCSS file in the project
    "@/assets/main.scss",
    "@fortawesome/fontawesome-svg-core/styles.css",
    "vue-toast-notification/dist/theme-default.css",
  ],
});
