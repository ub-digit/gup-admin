import Multiselect from "vue-multiselect";

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.component("Multiselect", Multiselect);
});
import "vue-multiselect/dist/vue-multiselect.css";
