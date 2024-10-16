import { name } from "./../../../node_modules/ci-info/index.d";
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
      // checks: ["pkce", "state"],
      profile(profile) {
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
    async signIn({ user, account, profile, email }) {
      console.log("signIn", user, account, profile);
      let userList = config.AUTH_USERS.split(",");
      console.log("profile2", profile);
      if (userList.includes(profile.account)) {
        return true;
      }
      return false;
    },
    /* on session retrival */
    async session({ session, user, token }) {
      console.log("session", session, user, token);
      return session;
    },
  },
});
