import { ComputedRef, Ref } from 'vue'
export type LayoutKey = string
declare module "/Users/johanlarsson/Dev/gup-super/frontend-nuxt/node_modules/nuxt/dist/pages/runtime/composables" {
  interface PageMeta {
    layout?: false | LayoutKey | Ref<LayoutKey> | ComputedRef<LayoutKey>
  }
}