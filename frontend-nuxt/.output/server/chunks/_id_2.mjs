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

const _id_ = defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  getQuery(event);
  const id = event.context.params.id;
  const res = await $fetch(`${config.API_BASE_URL}/publications/${id}`);
  return res;
});

export { _id_ as default };
//# sourceMappingURL=_id_2.mjs.map
