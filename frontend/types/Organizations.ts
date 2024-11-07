import zod from "zod";

export const zOrganization = zod.object({
  id: zod.number(),
  orgdbid: zod.string().nullish(),
  orgnr: zod.string().nullish(),
  parentid: zod.number().nullish(),
  grandparentid: zod.number().nullish(),
  faculty_id: zod.number().nullish(),
  name: zod.string().nullish(),
  name_sv: zod.string().nullish(),
  name_en: zod.string().nullish(),
  start_year: zod.number().nullish(),
  end_year: zod.number().nullish(),
  created_at: zod.string().nullish(),
  updated_at: zod.string().nullish(),
  created_by: zod.string().nullish(),
  updated_by: zod.string().nullish(),
});

export const zOrganizationArray = zod.array(zOrganization);

export const zOrganizationResultList = zod.object({
  showing: zod.number(),
  total: zod.number(),
  data: zOrganizationArray,
});

export const zOrganizationSearchResultList = zod.object({
  data: zOrganizationArray,
});

export type Organization = zod.infer<typeof zOrganization>;
export type OrganizationArray = zod.infer<typeof zOrganizationArray>;
export type OrganizationResultList = zod.infer<typeof zOrganizationResultList>;
