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
import 'defu';
import 'ohash';
import 'ufo';
import 'unstorage';
import 'radix3';
import 'node:fs';
import 'node:url';
import 'pathe';

const _id__delete = defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  getQuery(event);
  console.log("deleted");
  const id = event.context.params.id;
  const res = $fetch(`${config.API_BASE_URL}/publications/${id}`, { method: "DELETE" });
  return res;
});

export { _id__delete as default };
//# sourceMappingURL=_id_.delete.mjs.map
