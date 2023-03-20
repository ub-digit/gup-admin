import { u as useGupPostsStore, _ as __nuxt_component_0, a as __nuxt_component_2 } from "./gup_posts-d95dd8d0.js";
import { _ as __nuxt_component_0$1 } from "./Spinner-cea46663.js";
import { u as useI18n, b as useRouter, d as useRoute, s as storeToRefs } from "../server.mjs";
import { withAsyncContext, unref, useSSRContext } from "vue";
import "hookable";
import "destr";
import { ssrRenderAttrs, ssrRenderComponent, ssrInterpolate } from "vue/server-renderer";
import "ohash";
import "ofetch";
import "#internal/nitro";
import "unctx";
import "@vue/devtools-api";
import "@unhead/ssr";
import "unhead";
import "@unhead/shared";
import "vue-router";
import "h3";
import "ufo";
import "defu";
const _sfc_main = {
  __name: "[gupid]",
  __ssrInlineRender: true,
  async setup(__props) {
    let __temp, __restore;
    useI18n();
    useRouter();
    const route = useRoute();
    const gupPostsStore = useGupPostsStore();
    const { fetchGupPostById } = gupPostsStore;
    const { gupPostById, pendingGupPostById, errorGupPostById } = storeToRefs(gupPostsStore);
    [__temp, __restore] = withAsyncContext(() => fetchGupPostById(route.params.gupid)), await __temp, __restore();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_ErrorLoadingPost = __nuxt_component_0;
      const _component_Spinner = __nuxt_component_0$1;
      const _component_PostDisplay = __nuxt_component_2;
      _push(`<div${ssrRenderAttrs(_attrs)}>`);
      if (unref(errorGupPostById)) {
        _push(ssrRenderComponent(_component_ErrorLoadingPost, { error: unref(errorGupPostById) }, null, _parent));
      } else {
        _push(`<div><div class="row"><div class="col"><h2 class="pb-0 mb-4">${ssrInterpolate(unref(gupPostById).title)}</h2></div>`);
        if (unref(pendingGupPostById)) {
          _push(`<div class="col-auto">`);
          _push(ssrRenderComponent(_component_Spinner, { class: "me-4" }, null, _parent));
          _push(`</div>`);
        } else {
          _push(`<!---->`);
        }
        _push(`</div><div class="row"><div class="col">`);
        _push(ssrRenderComponent(_component_PostDisplay, { post: unref(gupPostById) }, null, _parent));
        _push(`</div></div></div>`);
      }
      _push(`</div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/publications/post/[id]/gup/[gupid].vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};
export {
  _sfc_main as default
};
//# sourceMappingURL=_gupid_-71dea7f7.js.map
