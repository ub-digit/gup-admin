import { ComputedRef, Ref } from 'vue'
export type LayoutKey = string
declare module "/home/lars/Documents/workspaces/gup-admin/frontend-nuxt/node_modules/nuxt/dist/pages/runtime/composables" {
  interface PageMeta {
    layout?: false | LayoutKey | Ref<LayoutKey> | ComputedRef<LayoutKey>
  }
}