import { z } from "zod";

export const zPublicationType = z.object({
  publication_type_code: z.string(),
  publication_type_id: z.number(),
  publication_type_label: z.string(),
});

export const zPublicationCompareArray = z.array(zPublicationType);

export type PublicationType = z.infer<typeof zPublicationType>;
