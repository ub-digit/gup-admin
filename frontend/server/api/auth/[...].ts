import { name } from "./../../../node_modules/ci-info/index.d";
import type { Profile } from "./../../../node_modules/next-auth/core/types.d";
import { NuxtAuthHandler } from "#auth";

import GithubProvider from "next-auth/providers/github";
const config = useRuntimeConfig();
export default NuxtAuthHandler({
  secret: config.SECRET_KEY_BASE,
  providers: [
    // @ts-expect-error You need to use .default here for it to work during SSR. May be fixed via Vite at some point
    GithubProvider.default({
      clientId: config.GITHUB_CLIENT_ID,
      clientSecret: config.GITHUB_CLIENT_SECRET,
      profile(profile) {
        return {
          id: profile.id.toString(),
          name: profile.login,
          email: profile.email,
          image: profile.avatar_url,
        };
      },
    }),
    {
      id: "GU",
      name: "GU",
      type: "oauth",
      wellKnown: "https://idp.auth.gu.se/adfs/.well-known/openid-configuration",
      authorization: { params: { scope: "openid email profile" } },
      idToken: true,
      clientId: config.GU_CLIENT_ID,
      clientSecret: config.GU_CLIENT_SECRET,
      async profile(profile) {
        return {
          id: profile.sub,
          name: profile.account,
          email: profile.email,
          account: profile.account,
        };
      },
    },
  ],
  pages: {
    signIn: "/login",
    error: "/login",
  },
  callbacks: {
    /* on before signin */
    async signIn({ user, profile }) {
      let userList = config.AUTH_USERS.split(",");
      // if github use login, if GU use account
      let accountName = profile.account ? profile.account : profile.login;
      if (userList.includes(accountName)) {
        return true;
      }
      return false;
    },
  },
});
