import { NuxtAuthHandler } from "#auth";

import GithubProvider from "next-auth/providers/github";
const config = useRuntimeConfig();
console.log("config", config);
export default NuxtAuthHandler({
  secret: config.SECRET_KEY_BASE,
  providers: [
    // @ts-expect-error You need to use .default here for it to work during SSR. May be fixed via Vite at some point
    GithubProvider.default({
      clientId: config.GITHUB_CLIENT_ID,
      clientSecret: config.GITHUB_CLIENT_SECRET,
    }),
  ],
  pages: {
    signIn: "/login",
  },
});
