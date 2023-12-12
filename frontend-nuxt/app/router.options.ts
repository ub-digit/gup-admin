import type { RouterConfig } from "@nuxt/schema";

export default <RouterConfig>{
  scrollBehavior(to, _from, savedPosition) {
    return new Promise((resolve, _reject) => {
      setTimeout(() => {
        if (savedPosition) {
          resolve(savedPosition);
        } else {
          if (to.hash) {
            resolve({
              el: to.hash,
              top: 0,
            });
          } else if (to.name === "publications-post-id-gup-gupid-tab-authors") {
            resolve({});
          } else {
            resolve({ top: 0 });
          }
        }
      }, 0);
    });
  },
};
