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
