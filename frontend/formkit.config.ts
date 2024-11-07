import { defineFormKitConfig } from "@formkit/vue";
import { sv } from "@formkit/i18n";
import { rootClasses } from "./formkit.theme";
import { generateClasses } from "@formkit/themes";

import {
  createProPlugin,
  rating,
  toggle,
  repeater,
  autocomplete,
} from "@formkit/pro";

// Create the Pro plugin with your `Project Key` and desired Pro Inputs:
const proPlugin = createProPlugin("fk-981c46f928", {
  // move to env
  rating,
  toggle,
  repeater,
  autocomplete,
  // any other Pro Inputs
});

export default defineFormKitConfig({
  config: {
    rootClasses,
    classes: generateClasses({
      global: {
        // applies to all input types
        messages: "list-unstyled",
        message: "invalid-feedback d-block",
        inner: "$remove:shadow",
      },
    }),
  },
  plugins: [proPlugin],
  // rules: {},
  locales: { sv },
  locale: "sv",
  // etc.
});
