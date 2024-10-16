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

    /* Google OAuth 
    {
  "key": "da798a9a-cfea-4bd6-8158-54d0226bded3",
  "secret": "aiwVj3J_oi8W7_X9EZdN0xx6hJRfQ6Bn9Jta9AoP",
  "well_known_url": "https://idp.auth.gu.se/adfs/.well-known/openid-configuration",
  "scope": "openid profile email"
}
    
    */
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
          login: profile.account,
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
    async signIn({ user, account, profile, email, credentials }) {
      console.log("signIn", user, account, profile, email, credentials);
      let userList = config.AUTH_USERS.split(",");
      console.log("users2", userList);
      console.log("profile2", profile);
      if (userList.includes(profile.login)) {
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
