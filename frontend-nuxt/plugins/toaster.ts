import { useToast } from 'vue-toast-notification';
const toast = useToast({position: 'top'});
export default defineNuxtPlugin(() => {
    return {
      provide: {
        toast,
      }
    }
});