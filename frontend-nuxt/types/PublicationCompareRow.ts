import { z } from "zod";

const zString = z.object({ value: z.string().nullable() });
const zAuthor = z.object({
  value: z.array(z.object({ name: z.string() })),
});
const zUrl = z.object({
  value: z.union([
    z.object({
      url: z.null(),
      display_title: z.null(),
    }),
    z.object({
      url: z.string(),
      display_title: z.string(),
    }),
  ]),
});

const zTitle = z.object({
  value: z.object({ url: z.string(), title: z.string() }),
});

const zMetaItem = z.object({
  display_label: z.string(),
  value: z.union([z.string(), z.null(), z.boolean()]),
});
const zMeta = z.object({
  value: z.object({
    attended: zMetaItem,
    created_at: zMetaItem,
    source: zMetaItem,
    updated_at: zMetaItem,
    version_created_by: zMetaItem,
    version_updated_by: zMetaItem,
  }),
});

const zSource = z.object({
  value: z.object({
    sourceissue: z.string(),
    sourcepages: z.string(),
    sourcevolume: z.string(),
  }),
});
const zPublicationCompareRow = z.object({
  diff: z.boolean(),
  display_label: z.string().optional(),
  display_type: z.string(),
  first: z.union([zString, zAuthor, zUrl, zTitle, zMeta, zSource]),
  second: z.union([zString, zAuthor, zUrl, zTitle, zMeta, zSource]).optional(),
  visibility: z.string(),
});

export const zPublicationCompareRowArray = z.array(zPublicationCompareRow);
export type PublicationCompareRow = z.infer<typeof zPublicationCompareRow>;
