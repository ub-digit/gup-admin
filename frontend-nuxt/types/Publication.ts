import { z } from "zod";

const zAuthor = z.object({ id: z.number().nullable(), name: z.string() });

export const zPublication = z.object({
  title: z.string(),
  id: z.string(),
  source: z.string(),
  publication_type_label: z.string(),
  publication_type_id: z.number(),
  pubyear: z.string(),
  authors: z.array(zAuthor),
});

export const zPublicationArray = z.object({
  data: z.array(zPublication),
  showing: z.number(),
  total: z.number(),
});
export type Publication = z.infer<typeof zPublication>;
