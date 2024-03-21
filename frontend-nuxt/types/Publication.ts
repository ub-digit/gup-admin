import { z } from "zod";

const zAuthor = z.object({ id: z.number().nullable(), name: z.string() });

export const zPublication = z.object({
  title: z.string().nullable(),
  id: z.string(),
  source: z.string().nullable(),
  publication_type_label: z.string().nullable(),
  publication_type_id: z.number().nullable(),
  pubyear: z.string().nullable(),
  authors: z.array(zAuthor).nullable(),
});

export const zPublicationArray = z.object({
  data: z.array(zPublication),
  showing: z.number(),
  total: z.number(),
});
export type Publication = z.infer<typeof zPublication>;
