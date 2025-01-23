import { zAuthorArray } from "./Author";
import { z } from "zod";

export const zIdentifier = z.object({
  code: z.string(),
  value: z.string(),
});

export const zIdentifierArray = z.array(zIdentifier);

export type Identifier = z.infer<typeof zIdentifier>;
export type IdentifierArray = z.infer<typeof zIdentifierArray>;
