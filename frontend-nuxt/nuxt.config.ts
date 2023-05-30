// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    ssr: true,
    runtimeConfig: {
        API_BASE_URL: 'http://localhost:4000/',
        public: {
          API_GUP_BASE_URL_EDIT: 'https://gup-lab.ub.gu.se/publications/show/',
          API_GUP_BASE_URL_SHOW: 'https://gup-lab.ub.gu.se/publications/show/',
        
        }
    },
    typescript: {
        shim: false
    },
    modules: [
        '@pinia/nuxt',
        '@vueuse/nuxt'
    ],
    build: {
        transpile: [
          '@fortawesome/fontawesome-svg-core',
          '@fortawesome/free-brands-svg-icons',
          '@fortawesome/free-regular-svg-icons',
          '@fortawesome/free-solid-svg-icons',
          '@fortawesome/vue-fontawesome'
        ]
      },
    css: [
        // SCSS file in the project
        '@/assets/main.scss',
        '@fortawesome/fontawesome-svg-core/styles.css',
        'vue-toast-notification/dist/theme-default.css'
      ],
})