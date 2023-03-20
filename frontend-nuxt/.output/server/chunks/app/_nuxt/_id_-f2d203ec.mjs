import { u as useGupPostsStore, _ as __nuxt_component_0$1, a as __nuxt_component_2 } from './gup_posts-d95dd8d0.mjs';
import { _ as __nuxt_component_0 } from './Spinner-cea46663.mjs';
import { u as useI18n, d as useRoute, b as useRouter, f as useNuxtApp, s as storeToRefs, g as __nuxt_component_4, a as _export_sfc, e as __nuxt_component_0$2 } from '../server.mjs';
import { ref, withAsyncContext, watch, unref, useSSRContext, withCtx, createVNode, toDisplayString, createTextVNode } from 'vue';
import { ssrRenderComponent, ssrRenderClass, ssrInterpolate, ssrRenderList, ssrRenderAttr, ssrRenderAttrs } from 'vue/server-renderer';
import { u as useFilterStore, a as useImportedPostsStore, b as useDebounceFn } from './imported_posts-1f7e588c.mjs';
import 'ohash';
import 'ofetch';
import 'hookable';
import 'unctx';
import '@unhead/ssr';
import 'unhead';
import '@unhead/shared';
import 'vue-router';
import 'h3';
import 'ufo';
import 'defu';
import '../../nitro/node-server.mjs';
import 'node-fetch-native/polyfill';
import 'node:http';
import 'node:https';
import 'destr';
import 'unenv/runtime/fetch/index';
import 'scule';
import 'unstorage';
import 'radix3';
import 'node:fs';
import 'node:url';
import 'pathe';
import 'lodash';

const _sfc_main$1 = {
  __name: "PostRowGup",
  __ssrInlineRender: true,
  props: ["post", "refresh"],
  setup(__props) {
    useI18n();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_NuxtLink = __nuxt_component_0$2;
      _push(`<div${ssrRenderAttrs(_attrs)} data-v-986e25ca>`);
      _push(ssrRenderComponent(_component_NuxtLink, {
        to: { name: "publications-post-id-gup-gupid", query: _ctx.$route.query, params: { gupid: __props.post.gup_id } },
        class: "list-group-item list-group-item-action"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<div class="d-flex w-100 justify-content-between" data-v-986e25ca${_scopeId}><h5 class="title mb-1" data-v-986e25ca${_scopeId}>${ssrInterpolate(__props.post.title)}</h5><small class="text-muted" data-v-986e25ca${_scopeId}>GUP-ID: ${ssrInterpolate(__props.post.gup_id)}</small></div><p class="mb-0" data-v-986e25ca${_scopeId}>${ssrInterpolate(__props.post.date)}</p><small data-v-986e25ca${_scopeId}>${ssrInterpolate(__props.post.pubtype)}<br data-v-986e25ca${_scopeId}> ${ssrInterpolate(__props.post.number_of_authors)} f\xF6rfattare</small>`);
          } else {
            return [
              createVNode("div", { class: "d-flex w-100 justify-content-between" }, [
                createVNode("h5", { class: "title mb-1" }, toDisplayString(__props.post.title), 1),
                createVNode("small", { class: "text-muted" }, "GUP-ID: " + toDisplayString(__props.post.gup_id), 1)
              ]),
              createVNode("p", { class: "mb-0" }, toDisplayString(__props.post.date), 1),
              createVNode("small", null, [
                createTextVNode(toDisplayString(__props.post.pubtype), 1),
                createVNode("br"),
                createTextVNode(" " + toDisplayString(__props.post.number_of_authors) + " f\xF6rfattare", 1)
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
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/PostRowGup.vue");
  return _sfc_setup$1 ? _sfc_setup$1(props, ctx) : void 0;
};
const __nuxt_component_3 = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["__scopeId", "data-v-986e25ca"]]);
const _sfc_main = {
  __name: "[id]",
  __ssrInlineRender: true,
  async setup(__props) {
    let __temp, __restore;
    const { t } = useI18n();
    const route = useRoute();
    useRouter();
    const searchTitleStr = ref(null);
    useNuxtApp();
    useFilterStore();
    const importedPostsStore = useImportedPostsStore();
    const { fetchImportedPostById, removeImportedPost, fetchImportedPosts } = importedPostsStore;
    const { importedPostById, pendingImportedPostById, errorImportedPostById } = storeToRefs(importedPostsStore);
    const gupPostsStore = useGupPostsStore();
    const { fetchGupPostsByTitle, fetchGupPostsById } = gupPostsStore;
    const { gupPostsByTitle, pendingGupPostsByTitle, gupPostsById, pendingGupPostsById, gupPostById, pendingGupPostById } = storeToRefs(gupPostsStore);
    [__temp, __restore] = withAsyncContext(() => fetchImportedPostById(route.params.id)), await __temp, __restore();
    searchTitleStr.value = importedPostById.value ? importedPostById.value.title : "";
    if (importedPostById.value) {
      [__temp, __restore] = withAsyncContext(() => fetchGupPostsById(importedPostById.value.id)), await __temp, __restore();
      [__temp, __restore] = withAsyncContext(() => fetchGupPostsByTitle(importedPostById.value.id, importedPostById.value.title)), await __temp, __restore();
    }
    const debounceFn = useDebounceFn(() => {
      if (importedPostById) {
        fetchGupPostsByTitle({ title: searchTitleStr.value });
      }
    }, 500);
    watch(
      searchTitleStr,
      () => {
        debounceFn();
      }
    );
    return (_ctx, _push, _parent, _attrs) => {
      const _component_ErrorLoadingPost = __nuxt_component_0$1;
      const _component_Spinner = __nuxt_component_0;
      const _component_PostDisplay = __nuxt_component_2;
      const _component_PostRowGup = __nuxt_component_3;
      const _component_NuxtPage = __nuxt_component_4;
      _push(`<!--[--><div class="col-6">`);
      if (unref(errorImportedPostById)) {
        _push(ssrRenderComponent(_component_ErrorLoadingPost, { error: unref(errorImportedPostById) }, null, _parent));
      } else {
        _push(`<div><div class="row"><div class="${ssrRenderClass([{ "opacity-50": unref(pendingImportedPostById) }, "col"])}"><h2 class="pb-0 mb-4">${ssrInterpolate(unref(importedPostById).title)}</h2></div><div class="col-auto">`);
        if (unref(pendingGupPostsByTitle) || unref(pendingGupPostsById) || unref(pendingImportedPostById)) {
          _push(ssrRenderComponent(_component_Spinner, { class: "me-4" }, null, _parent));
        } else {
          _push(`<!---->`);
        }
        _push(`</div></div><div class="row"><div class="col">`);
        _push(ssrRenderComponent(_component_PostDisplay, {
          class: { "opacity-50": unref(pendingImportedPostById) },
          post: unref(importedPostById)
        }, null, _parent));
        _push(`</div></div><div class="row pb-4"><div class="col text-end"><button type="button" class="btn btn-danger me-1">${ssrInterpolate(unref(t)("buttons.remove"))}</button><button type="button" class="btn btn-secondary me-1">${ssrInterpolate(unref(t)("buttons.edit"))}</button><button type="button" class="btn btn-success">${ssrInterpolate(unref(t)("buttons.merge"))}</button></div></div><h3 class="mb-4">${ssrInterpolate(unref(t)("views.publications.post.result_list.header"))}</h3><div class="row pb-4"><div class="col"><h4 class="mb-1 text-muted">${ssrInterpolate(unref(t)("views.publications.post.result_list_by_id.header"))}</h4>`);
        if (!unref(gupPostsById).length) {
          _push(`<div>${ssrInterpolate(unref(t)("views.publications.post.result_list.no_gup_posts_by_id_found"))}</div>`);
        } else {
          _push(`<div class="${ssrRenderClass([{ "opacity-50": unref(pendingGupPostsById) }, "list-group list-group-flush border-bottom"])}"><!--[-->`);
          ssrRenderList(unref(gupPostsById), (post) => {
            _push(ssrRenderComponent(_component_PostRowGup, {
              post,
              refresh: _ctx.$route.query,
              key: post.id
            }, null, _parent));
          });
          _push(`<!--]--></div>`);
        }
        _push(`</div></div><div class="row"><div class="col"><div class="row"><div class="col"><h4 class="mb-1 text-muted">${ssrInterpolate(unref(t)("views.publications.post.result_list_by_title.header"))}</h4></div><div class="col-auto">`);
        if (unref(pendingGupPostsByTitle)) {
          _push(ssrRenderComponent(_component_Spinner, { class: "me-4" }, null, _parent));
        } else {
          _push(`<!---->`);
        }
        _push(`</div></div><div class="row"><div class="col"><label class="d-none" for="title-search">S\xF6k p\xE5 titel</label><input id="title-search" class="form-control mb-3" type="search"${ssrRenderAttr("value", unref(searchTitleStr))}>`);
        if (!unref(gupPostsByTitle).length) {
          _push(`<div>${ssrInterpolate(unref(t)("views.publications.post.result_list.no_gup_posts_by_title_found"))}</div>`);
        } else {
          _push(`<div class="${ssrRenderClass([{ "opacity-50": unref(pendingGupPostsByTitle) }, "list-group list-group-flush border-bottom"])}"><!--[-->`);
          ssrRenderList(unref(gupPostsByTitle), (post) => {
            _push(ssrRenderComponent(_component_PostRowGup, {
              post,
              key: post.id
            }, null, _parent));
          });
          _push(`<!--]--></div>`);
        }
        _push(`</div></div></div></div></div>`);
      }
      _push(`</div><div class="col-6">`);
      _push(ssrRenderComponent(_component_NuxtPage, null, null, _parent));
      _push(`</div><!--]-->`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/publications/post/[id].vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=_id_-f2d203ec.mjs.map
