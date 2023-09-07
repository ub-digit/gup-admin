import { defineEventHandler, getQuery } from 'h3';
import { u as useRuntimeConfig } from './nitro/node-server.mjs';
import 'node-fetch-native/polyfill';
import 'node:http';
import 'node:https';
import 'destr';
import 'ofetch';
import 'unenv/runtime/fetch/index';
import 'hookable';
import 'scule';
import 'klona';
import 'defu';
import 'ohash';
import 'ufo';
import 'unstorage';
import 'radix3';
import 'node:fs';
import 'node:url';
import 'pathe';

const posts_imported = defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  console.log(query);
  const res = await $fetch(`${config.API_BASE_URL}/publications`, {
    params: query
  });
  return res;
});

export { posts_imported as default };
//# sourceMappingURL=posts_imported.mjs.map
