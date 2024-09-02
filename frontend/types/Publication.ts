import { z } from "zod";

const zAuthorAffiliation = z.object({
  id: z.number().nullable(),
  name: z.string(),
  affiliation_str: z.string().nullish(),
});

export const zPublication = z.object({
  title: z.string(),
  id: z.string(),
  source: z.string(),
  publication_type_label: z.string(),
  publication_type_id: z.number(),
  pubyear: z.string(),
  authors: z.array(zAuthorAffiliation),
});

export const zPublicationArray = z.object({
  data: z.array(zPublication),
  showing: z.number(),
  total: z.number(),
});

export const zAuthorAffiliationArray = z.object({
  data: z.array(zAuthorAffiliation),
});

export type Publication = z.infer<typeof zPublication>;
export type AuthorAffiliation = z.infer<typeof zAuthorAffiliation>;
export type AuthorAffiliationArray = z.infer<typeof zAuthorAffiliationArray>;
