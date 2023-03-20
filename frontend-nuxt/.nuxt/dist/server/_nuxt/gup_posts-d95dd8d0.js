import { resolveComponent, mergeProps, useSSRContext, unref, withCtx, createTextVNode, toDisplayString, createVNode, openBlock, createBlock, Fragment, renderList, ref } from "vue";
import { ssrRenderAttrs, ssrRenderComponent, ssrInterpolate, ssrRenderSlot, ssrRenderList, ssrRenderAttr } from "vue/server-renderer";
import { u as useI18n, a as _export_sfc, h as defineStore } from "../server.mjs";
import "hookable";
import { u as useFetch } from "./Spinner-cea46663.js";
import "destr";
const _sfc_main$3 = {
  __name: "ErrorLoadingPost",
  __ssrInlineRender: true,
  props: ["error"],
  setup(__props) {
    return (_ctx, _push, _parent, _attrs) => {
      const _component_font_awesome_icon = resolveComponent("font-awesome-icon");
      if (__props.error) {
        _push(`<div${ssrRenderAttrs(mergeProps({ class: "row" }, _attrs))}><div class="col text-center"><h2 class="mb-2 text-danger">`);
        _push(ssrRenderComponent(_component_font_awesome_icon, { icon: "fa-solid fa-circle-exclamation" }, null, _parent));
        _push(` ${ssrInterpolate(__props.error.statusCode)}</h2><p>${ssrInterpolate(__props.error.message)}</p></div></div>`);
      } else {
        _push(`<!---->`);
      }
    };
  }
};
const _sfc_setup$3 = _sfc_main$3.setup;
_sfc_main$3.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/ErrorLoadingPost.vue");
  return _sfc_setup$3 ? _sfc_setup$3(props, ctx) : void 0;
};
const __nuxt_component_0$1 = _sfc_main$3;
const _sfc_main$2 = {
  __name: "PostMeta",
  __ssrInlineRender: true,
  props: ["post"],
  setup(__props) {
    const props = __props;
    const { t } = useI18n();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_font_awesome_icon = resolveComponent("font-awesome-icon");
      _push(`<div${ssrRenderAttrs(_attrs)}><ul class="list-inline"><li class="list-inline-item">`);
      _push(ssrRenderComponent(_component_font_awesome_icon, {
        class: "text-danger",
        icon: "fa-solid fa-flag"
      }, null, _parent));
      _push(` ${ssrInterpolate(unref(t)("views.publications.form.needs_attention"))}</li><li class="list-inline-item">`);
      _push(ssrRenderComponent(_component_font_awesome_icon, {
        class: "text-info",
        icon: "fa-solid fa-file-arrow-down"
      }, null, _parent));
      _push(` ${ssrInterpolate(unref(t)("views.publications.post.import_from_scopus"))}</li><li class="list-inline-item">`);
      _push(ssrRenderComponent(_component_font_awesome_icon, {
        class: "text-warning",
        icon: "fa-solid fa-award"
      }, null, _parent));
      _push(` ${ssrInterpolate(props.post.date)} ${ssrInterpolate(unref(t)("views.publications.post.by"))} ${ssrInterpolate(props.post.creator)}</li></ul></div>`);
    };
  }
};
const _sfc_setup$2 = _sfc_main$2.setup;
_sfc_main$2.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/PostMeta.vue");
  return _sfc_setup$2 ? _sfc_setup$2(props, ctx) : void 0;
};
const __nuxt_component_0 = _sfc_main$2;
const _sfc_main$1 = {};
function _sfc_ssrRender(_ctx, _push, _parent, _attrs) {
  _push(`<div${ssrRenderAttrs(mergeProps({ class: "row mb-2" }, _attrs))}><div class="col-4 fw-bold">`);
  ssrRenderSlot(_ctx.$slots, "label", {}, null, _push, _parent);
  _push(`</div><div class="col-8">`);
  ssrRenderSlot(_ctx.$slots, "content", {}, null, _push, _parent);
  _push(`</div></div>`);
}
const _sfc_setup$1 = _sfc_main$1.setup;
_sfc_main$1.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/PostField.vue");
  return _sfc_setup$1 ? _sfc_setup$1(props, ctx) : void 0;
};
const __nuxt_component_1 = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["ssrRender", _sfc_ssrRender]]);
const _sfc_main = {
  __name: "PostDisplay",
  __ssrInlineRender: true,
  props: ["post"],
  setup(__props) {
    const { t } = useI18n();
    return (_ctx, _push, _parent, _attrs) => {
      const _component_PostMeta = __nuxt_component_0;
      const _component_PostField = __nuxt_component_1;
      _push(`<div${ssrRenderAttrs(_attrs)}>`);
      _push(ssrRenderComponent(_component_PostMeta, {
        class: "mb-4",
        post: __props.post
      }, null, _parent));
      _push(`<div class="fields mb-4">`);
      _push(ssrRenderComponent(_component_PostField, null, {
        label: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.publications.post.fields.pubtype"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.publications.post.fields.pubtype")), 1)
            ];
          }
        }),
        content: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(__props.post.pubtype)}`);
          } else {
            return [
              createTextVNode(toDisplayString(__props.post.pubtype), 1)
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_PostField, null, {
        label: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.publications.post.fields.published_in"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.publications.post.fields.published_in")), 1)
            ];
          }
        }),
        content: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(__props.post.published_in)}`);
          } else {
            return [
              createTextVNode(toDisplayString(__props.post.published_in), 1)
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_PostField, null, {
        label: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.publications.post.fields.pubyear"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.publications.post.fields.pubyear")), 1)
            ];
          }
        }),
        content: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(__props.post.date)}`);
          } else {
            return [
              createTextVNode(toDisplayString(__props.post.date), 1)
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_PostField, null, {
        label: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.publications.post.fields.author"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.publications.post.fields.author")), 1)
            ];
          }
        }),
        content: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<ul class="list-unstyled mb-0"${_scopeId}><!--[-->`);
            ssrRenderList(__props.post.authors, (author) => {
              _push2(`<li${_scopeId}>${ssrInterpolate(author.name)}</li>`);
            });
            _push2(`<!--]--></ul>`);
          } else {
            return [
              createVNode("ul", { class: "list-unstyled mb-0" }, [
                (openBlock(true), createBlock(Fragment, null, renderList(__props.post.authors, (author) => {
                  return openBlock(), createBlock("li", {
                    key: author.id
                  }, toDisplayString(author.name), 1);
                }), 128))
              ])
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_PostField, null, {
        label: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.publications.post.fields.doi"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.publications.post.fields.doi")), 1)
            ];
          }
        }),
        content: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`<a${ssrRenderAttr("href", __props.post.doi)} target="_blank"${_scopeId}>${ssrInterpolate(__props.post.doi)}</a>`);
          } else {
            return [
              createVNode("a", {
                href: __props.post.doi,
                target: "_blank"
              }, toDisplayString(__props.post.doi), 9, ["href"])
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(ssrRenderComponent(_component_PostField, null, {
        label: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            _push2(`${ssrInterpolate(unref(t)("views.publications.post.fields.scopus"))}`);
          } else {
            return [
              createTextVNode(toDisplayString(unref(t)("views.publications.post.fields.scopus")), 1)
            ];
          }
        }),
        content: withCtx((_, _push2, _parent2, _scopeId) => {
          if (_push2) {
            if (__props.post.scopus_id) {
              _push2(`<span${_scopeId}><a${ssrRenderAttr("href", __props.post.scopus_id)}${_scopeId}>${ssrInterpolate(__props.post.scopus_id)}</a></span>`);
            } else {
              _push2(`<span class="badge bg-danger"${_scopeId}>${ssrInterpolate(unref(t)("views.publications.post.fields.scopus_missing"))}</span>`);
            }
          } else {
            return [
              __props.post.scopus_id ? (openBlock(), createBlock("span", { key: 0 }, [
                createVNode("a", {
                  href: __props.post.scopus_id
                }, toDisplayString(__props.post.scopus_id), 9, ["href"])
              ])) : (openBlock(), createBlock("span", {
                key: 1,
                class: "badge bg-danger"
              }, toDisplayString(unref(t)("views.publications.post.fields.scopus_missing")), 1))
            ];
          }
        }),
        _: 1
      }, _parent));
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/PostDisplay.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};
const __nuxt_component_2 = _sfc_main;
const useGupPostsStore = defineStore("gupPostsStore", () => {
  const gupPostsByTitle = ref([]);
  const gupPostsById = ref([]);
  const gupPostById = ref({});
  const errorGupPostById = ref(null);
  const pendingGupPostsByTitle = ref(null);
  const pendingGupPostsById = ref(null);
  const pendingGupPostById = ref(null);
  async function fetchGupPostsById(id) {
    try {
      pendingGupPostsById.value = true;
      const { data, error } = await useFetch("/api/posts_gup_by_id", {
        params: { "id": id }
      }, "$w0APOedx6d");
      gupPostsById.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsById");
    } finally {
      pendingGupPostsById.value = false;
    }
  }
  async function fetchGupPostsByTitle(id, title) {
    try {
      pendingGupPostsByTitle.value = true;
      const { data, error } = await useFetch("/api/posts_gup_by_title", {
        params: { "id": id, "title": title }
      }, "$oMuPDkDbSk");
      gupPostsByTitle.value = data.value;
    } catch (error) {
      console.log("Something went wrong: fetchGupPostsByTitle");
    } finally {
      pendingGupPostsByTitle.value = false;
    }
  }
  async function fetchGupPostById(id) {
    try {
      pendingGupPostById.value = true;
      const { data, error } = await useFetch(`/api/post_gup/${id}`, "$q6Rl7pWoVX");
      if (error.value) {
        errorGupPostById.value = error.value.data;
      } else {
        gupPostById.value = data.value;
      }
    } catch (error) {
      console.log("Something went wrong: fetchGupPostById");
    } finally {
      pendingGupPostById.value = false;
    }
  }
  return { gupPostsByTitle, fetchGupPostsByTitle, pendingGupPostsByTitle, gupPostsById, fetchGupPostsById, pendingGupPostsById, gupPostById, errorGupPostById, fetchGupPostById, pendingGupPostById };
});
export {
  __nuxt_component_0$1 as _,
  __nuxt_component_2 as a,
  useGupPostsStore as u
};
//# sourceMappingURL=gup_posts-d95dd8d0.js.map
