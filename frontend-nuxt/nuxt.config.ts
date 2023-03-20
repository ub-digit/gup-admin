// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    ssr: true,
    runtimeConfig: {
        
        API_BASE_URL: 'http://130.241.221.53:8001',
        public: {
            
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