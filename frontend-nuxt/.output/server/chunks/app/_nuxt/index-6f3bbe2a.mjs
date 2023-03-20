import { u as useI18n, _ as __nuxt_component_0$1 } from '../server.mjs';
import { mergeProps, unref, withCtx, createTextVNode, toDisplayString, useSSRContext } from 'vue';
import { ssrRenderAttrs, ssrInterpolate, ssrRenderComponent } from 'vue/server-renderer';
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
import 'ohash';
import 'unstorage';
import 'radix3';
import 'node:fs';
import 'node:url';
import 'pathe';

const _sfc_main = {
  __name: "index",
  __ssrInlineRender: true,
  setup(__props) {
    const { t } = useI18n();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_LangLink = __nuxt_component_0$1;
      _push(`<div${ssrRenderAttrs(mergeProps({ class: "container" }, _attrs))}><div class="row pt-5"><div class="col"><div class="card"><div class="card-body"><h2 class="card-title">${ssrInterpolate(unref(t)("views.index.card.publications.header"))}</h2><p class="card-text">${ssrInterpolate(unref(t)("views.index.card.publications.body"))}</p>`);
      _push(ssrRenderComponent(_component_LangLink, {
        to: "/publications",
        class: "btn btn-primary"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.index.card.publications.link_text"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.index.card.publications.link_text")), 1)
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div></div><div class="col"><div class="card"><div class="card-body"><h2 class="card-title">${ssrInterpolate(unref(t)("views.index.card.people.header"))}</h2><p class="card-text">${ssrInterpolate(unref(t)("views.index.card.people.body"))}</p>`);
      _push(ssrRenderComponent(_component_LangLink, {
        to: "/publications",
        class: "btn btn-primary"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.index.card.people.link_text"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.index.card.people.link_text")), 1)
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div></div><div class="col"><div class="card"><div class="card-body"><h2 class="card-title">${ssrInterpolate(unref(t)("views.index.card.all_data.header"))}</h2><p class="card-text">${ssrInterpolate(unref(t)("views.index.card.all_data.body"))}</p>`);
      _push(ssrRenderComponent(_component_LangLink, {
        to: "/publications",
        class: "btn btn-primary"
      }, {
        default: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.index.card.all_data.link_text"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.index.card.all_data.link_text")), 1)
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div></div></div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("pages/index.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};

export { _sfc_main as default };
//# sourceMappingURL=index-6f3bbe2a.mjs.map
