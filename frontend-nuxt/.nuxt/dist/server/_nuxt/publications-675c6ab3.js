import { defineComponent, ref, withAsyncContext, onUnmounted, watch, unref, useSSRContext, withCtx, createVNode, toDisplayString, openBlock, createBlock, createCommentVNode, createTextVNode } from "vue";
import { i as useHead, h as defineStore, u as useI18n, s as storeToRefs, a as _export_sfc, e as __nuxt_component_0$1, d as useRoute, b as useRouter, g as __nuxt_component_4 } from "../server.mjs";
import { u as useFetch, _ as __nuxt_component_0 } from "./Spinner-cea46663.js";
import { ssrRenderAttrs, ssrIncludeBooleanAttr, ssrLooseContain, ssrInterpolate, ssrRenderComponent, ssrRenderAttr, ssrRenderList, ssrRenderClass } from "vue/server-renderer";
import { u as useFilterStore, b as useDebounceFn, a as useImportedPostsStore } from "./imported_posts-1f7e588c.js";
import "hookable";
import "destr";
import "lodash";
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
import "ohash";
const removeUndefinedProps = (props) => Object.fromEntries(Object.entries(props).filter(([, value]) => value !== void 0));
const setupForUseMeta = (metaFactory, renderChild) => (props, ctx) => {
  useHead(() => metaFactory({ ...removeUndefinedProps(props), ...ctx.attrs }, ctx));
  return () => {
    var _a, _b;
    return renderChild ? (_b = (_a = ctx.slots).default) == null ? void 0 : _b.call(_a) : null;
  };
};
const globalProps = {
  accesskey: String,
  autocapitalize: String,
  autofocus: {
    type: Boolean,
    default: void 0
  },
  class: [String, Object, Array],
  contenteditable: {
    type: Boolean,
    default: void 0
  },
  contextmenu: String,
  dir: String,
  draggable: {
    type: Boolean,
    default: void 0
  },
  enterkeyhint: String,
  exportparts: String,
  hidden: {
    type: Boolean,
    default: void 0
  },
  id: String,
  inputmode: String,
  is: String,
  itemid: String,
  itemprop: String,
  itemref: String,
  itemscope: String,
  itemtype: String,
  lang: String,
  nonce: String,
  part: String,
  slot: String,
  spellcheck: {
    type: Boolean,
    default: void 0
  },
  style: String,
  tabindex: String,
  title: String,
  translate: String
};
const Meta = /* @__PURE__ */ defineComponent({
  // eslint-disable-next-line vue/no-reserved-component-names
  name: "Meta",
  inheritAttrs: false,
  props: {
    ...globalProps,
    charset: String,
    content: String,
    httpEquiv: String,
    name: String,
    body: Boolean,
    renderPriority: [String, Number]
  },
  setup: setupForUseMeta((props) => {
    const meta = { ...props };
    if (meta.httpEquiv) {
      meta["http-equiv"] = meta.httpEquiv;
      delete meta.httpEquiv;
    }
    return {
      meta: [meta]
    };
  })
});
const Head = /* @__PURE__ */ defineComponent({
  // eslint-disable-next-line vue/no-reserved-component-names
  name: "Head",
  inheritAttrs: false,
  setup: (_props, ctx) => () => {
    var _a, _b;
    return (_b = (_a = ctx.slots).default) == null ? void 0 : _b.call(_a);
  }
});
const usePublicationTypesStore = defineStore("publicationTypesStore", () => {
  const publicationTypes = ref([]);
  const pendingPublicationTypes = ref(null);
  async function fetchPublicationTypes(params) {
    try {
      pendingPublicationTypes.value = true;
      const { data, error } = await useFetch("/api/pubtypes", {
        params
      }, "$4JCIXpvuxF");
      pendingPublicationTypes.value = false;
      publicationTypes.value = data.value.publication_types;
    } catch (error) {
      console.log("Something went wrong: fetchPublicationTypes");
    }
  }
  return { publicationTypes, fetchPublicationTypes, pendingPublicationTypes };
});
const _sfc_main$2 = {
  __name: "Filters",
  __ssrInlineRender: true,
  props: ["pendingImportedPosts"],
  async setup(__props) {
    let __temp, __restore;
    const { t, getLocale } = useI18n();
    const publicationTypesStore = usePublicationTypesStore();
    const { fetchPublicationTypes } = publicationTypesStore;
    const { publicationTypes, pendingPublicationTypes } = storeToRefs(publicationTypesStore);
    [__temp, __restore] = withAsyncContext(() => fetchPublicationTypes({ lang: getLocale() })), await __temp, __restore();
    const filterStore = useFilterStore();
    const { $reset } = filterStore;
    const { filters } = storeToRefs(filterStore);
    const title_str = ref(filters.value.title);
    const debouncedFn = useDebounceFn(() => {
      filters.value.title = title_str.value;
    }, 500);
    onUnmounted(() => {
      $reset();
    });
    watch(
      title_str,
      () => {
        debouncedFn();
      }
    );
    return (_ctx, _push, _parent, _attrs) => {
      const _component_Spinner = __nuxt_component_0;
      _push(`<div${ssrRenderAttrs(_attrs)}><form class="col" id="filters"><div class="row"><div class="col"><div class="form-check col-auto form-switch mb-3"><input class="form-check-input" type="checkbox" id="needs_attention"${ssrIncludeBooleanAttr(Array.isArray(unref(filters).needs_attention) ? ssrLooseContain(unref(filters).needs_attention, null) : unref(filters).needs_attention) ? " checked" : ""}><label class="form-check-label" for="needs_attention">${ssrInterpolate(unref(t)("views.publications.form.needs_attention"))}</label></div></div><div class="col-auto">`);
      if (__props.pendingImportedPosts) {
        _push(ssrRenderComponent(_component_Spinner, { class: "me-4" }, null, _parent));
      } else {
        _push(`<!---->`);
      }
      _push(`</div></div><div class="mb-3"><div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="scopus"${ssrIncludeBooleanAttr(Array.isArray(unref(filters).scopus) ? ssrLooseContain(unref(filters).scopus, null) : unref(filters).scopus) ? " checked" : ""}><label class="form-check-label" for="scopus">${ssrInterpolate(unref(t)("views.publications.form.scopus_title"))}</label></div><div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="wos"${ssrIncludeBooleanAttr(Array.isArray(unref(filters).wos) ? ssrLooseContain(unref(filters).wos, null) : unref(filters).wos) ? " checked" : ""}><label class="form-check-label" for="wos">${ssrInterpolate(unref(t)("views.publications.form.wos_title"))}</label></div><div class="form-check form-check-inline"><input class="form-check-input" type="checkbox" id="manual"${ssrIncludeBooleanAttr(Array.isArray(unref(filters).manual) ? ssrLooseContain(unref(filters).manual, null) : unref(filters).manual) ? " checked" : ""}><label class="form-check-label" for="manual">${ssrInterpolate(unref(t)("views.publications.form.manual_title"))}</label></div></div><select class="form-select mb-3"${ssrRenderAttr("aria-label", unref(t)("views.publications.form.pub_type_select_label"))}><option value="" selected>${ssrInterpolate(unref(t)("views.publications.form.pub_type_select_label"))}</option><!--[-->`);
      ssrRenderList(unref(publicationTypes), (pubtype) => {
        _push(`<option${ssrRenderAttr("value", pubtype.id)}>${ssrInterpolate(pubtype.display_name)}</option>`);
      });
      _push(`<!--]--></select><div class="mb-3"><label for="title" class="form-label visually-hidden">${ssrInterpolate(unref(t)("views.publications.form.title_label"))}</label><input type="search"${ssrRenderAttr("value", unref(title_str))} class="form-control" id="title"${ssrRenderAttr("placeholder", unref(t)("views.publications.form.title_label"))}></div></form></div>`);
    };
  }
};
const _sfc_setup$2 = _sfc_main$2.setup;
_sfc_main$2.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/Filters.vue");
  return _sfc_setup$2 ? _sfc_setup$2(props, ctx) : void 0;
};
const __nuxt_component_2 = _sfc_main$2;
const PostRow_vue_vue_type_style_index_0_scoped_a99a7e19_lang = "";
const _sfc_main$1 = {
  __name: "PostRow",
  __ssrInlineRender: true,
  props: ["post"],
  setup(__props) {
    useI18n();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0$1;
      _push(`<div${ssrRenderAttrs(_attrs)} data-v-a99a7e19>`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: { name: "publications-post-id", query: _ctx.$route.query, params: { id: __props.post.id } },
        class: "list-group-item list-group-item-action"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<div class="d-flex w-100 justify-content-between" data-v-a99a7e19${_scopeId}><h5 class="title mb-1" data-v-a99a7e19${_scopeId}>${ssrInterpolate(__props.post.title)}</h5>`);
            if (__props.post.gup_id) {
              _push2(`<small class="text-muted" data-v-a99a7e19${_scopeId}>GUP-ID: ${ssrInterpolate(__props.post.gup_id)}</small>`);
            } else {
              _push2(`<!---->`);
            }
            _push2(`</div><p class="mb-0" data-v-a99a7e19${_scopeId}>${ssrInterpolate(__props.post.date)}</p><small data-v-a99a7e19${_scopeId}>Pubtype: ${ssrInterpolate(__props.post.pubtype)}<br data-v-a99a7e19${_scopeId}> ${ssrInterpolate(__props.post.number_of_authors)} författare</small>`);
          } else {
            return [
              createVNode("div", { class: "d-flex w-100 justify-content-between" }, [
                createVNode("h5", { class: "title mb-1" }, toDisplayString(__props.post.title), 1),
                __props.post.gup_id ? (openBlock(), createBlock("small", {
                  key: 0,
                  class: "text-muted"
                }, "GUP-ID: " + toDisplayString(__props.post.gup_id), 1)) : createCommentVNode("", true)
              ]),
              createVNode("p", { class: "mb-0" }, toDisplayString(__props.post.date), 1),
              createVNode("small", null, [
                createTextVNode("Pubtype: " + toDisplayString(__props.post.pubtype), 1),
                createVNode("br"),
                createTextVNode(" " + toDisplayString(__props.post.number_of_authors) + " författare", 1)
              ])
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div>`);
    };
  }
};
const _sfc_setup$1 = _sfc_main$1.setup;
_sfc_main$1.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/PostRow.vue");
  return _sfc_setup$1 ? _sfc_setup$1(props, ctx) : void 0;
};
const __nuxt_component_3 = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["__scopeId", "data-v-a99a7e19"]]);
const publications_vue_vue_type_style_index_0_lang = "";
const _sfc_main = {
  __name: "publications",
  __ssrInlineRender: true,
  async setup(__props) {
    let __temp, __restore;
    const { t, getLocale } = useI18n();
    useRoute();
    useRouter();
    const importedPostsStore = useImportedPostsStore();
    const { fetchImportedPosts } = importedPostsStore;
    const { importedPosts, pendingImportedPosts } = storeToRefs(importedPostsStore);
    [__temp, __restore] = withAsyncContext(() => fetchImportedPosts()), await __temp, __restore();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_Head = Head;
      const _component_Meta = Meta;
      const _component_Filters = __nuxt_component_2;
      const _component_PostRow = __nuxt_component_3;
      const _component_NuxtPage = __nuxt_component_4;
      _push(`<div${ssrRenderAttrs(_attrs)}>`);
      _push(ssrRenderComponent(_component_Head, null, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<title${_scopeId}>${ssrInterpolate(unref(t)("seo.application_title"))}</title>`);
            _push2(ssrRenderComponent(_component_Meta, {
              name: "description",
              content: unref(t)("seo.application_title")
            }, null, _parent2, _scopeId));
          } else {
            return [
              createVNode("title", null, toDisplayString(unref(t)("seo.application_title")), 1),
              createVNode(_component_Meta, {
                name: "description",
                content: unref(t)("seo.application_title")
              }, null, 8, ["content"])
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`<div class="container-fluid"><div class="row"><div class="col-4"><div class="row">`);
      _push(ssrRenderComponent(_component_Filters, { pendingImportedPosts: unref(pendingImportedPosts) }, null, _parent));
      _push(`</div><div id="result-list-by-id" class="row"><div class="${ssrRenderClass([{ "opacity-50": unref(pendingImportedPosts) }, "col scroll"])}">`);
      if (!unref(importedPosts).length) {
        _push(`<div>${ssrInterpolate(unref(t)("views.publications.result_list.no_imported_posts_found"))}</div>`);
      } else {
        _push(`<div class="list-group list-group-flush border-bottom"><!--[-->`);
        ssrRenderList(unref(importedPosts), (post) => {
          _push(ssrRenderComponent(_component_PostRow, {
            post,
            key: post.id
          }, null, _parent));
        });
        _push(`<!--]--></div>`);
      }
      _push(`</div></div></div><div class="col"><div class="row">`);
      _push(ssrRenderComponent(_component_NuxtPage, null, null, _parent));
      _push(`</div></div></div></div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/publications.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};
export {
  _sfc_main as default
};
//# sourceMappingURL=publications-675c6ab3.js.map
