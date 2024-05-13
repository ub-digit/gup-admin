// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: true,
  runtimeConfig: {
    API_BASE_URL: "http://localhost:40411/", // this should point to admin-backend
    public: {
      API_GUP_BASE_URL: "http://localhost:3010", // this should point to gup-frontend and is used to redirect to posts for show/edit in gup-frontend
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
  modules: ["@pinia/nuxt", "@vueuse/nuxt"],
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
