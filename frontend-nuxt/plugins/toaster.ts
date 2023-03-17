import { useToast } from 'vue-toast-notification';
const toast = useToast({position: 'top-right'});
export default defineNuxtPlugin(() => {
    return {
      provide: {
        toast,
      }
    }
});