import { resolveComponent, mergeProps, useSSRContext } from "vue";
import { ssrRenderAttrs, ssrRenderComponent } from "vue/server-renderer";
import { a as _export_sfc } from "../server.mjs";
const NothingSelected_vue_vue_type_style_index_0_scoped_c0d7aced_lang = "";
const _sfc_main = {
  __name: "NothingSelected",
  __ssrInlineRender: true,
  props: ["columnSize"],
  setup(__props) {
    const props = __props;
    return (_ctx, _push, _parent, _attrs) => {
      const _component_font_awesome_icon = resolveComponent("font-awesome-icon");
      _push(`<div${ssrRenderAttrs(mergeProps({
        class: [props.columnSize, "card"]
      }, _attrs))} data-v-c0d7aced><div class="card-body d-flex align-items-center justify-content-center" data-v-c0d7aced>`);
      _push(ssrRenderComponent(_component_font_awesome_icon, {
        class: "inline-block text-muted fa-10x",
        icon: "fa-regular fa-file"
      }, null, _parent));
      _push(`</div></div>`);
    };
  }
};
const _sfc_setup = _sfc_main.setup;
_sfc_main.setup = (props, ctx) => {
  const ssrContext = useSSRContext();
  (ssrContext.modules || (ssrContext.modules = /* @__PURE__ */ new Set())).add("components/NothingSelected.vue");
  return _sfc_setup ? _sfc_setup(props, ctx) : void 0;
};
const __nuxt_component_0 = /* @__PURE__ */ _export_sfc(_sfc_main, [["__scopeId", "data-v-c0d7aced"]]);
export {
  __nuxt_component_0 as _
};
//# sourceMappingURL=NothingSelected-59695c61.js.map
