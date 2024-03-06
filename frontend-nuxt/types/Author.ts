import { z } from "zod";

export const zDepartment = z.object({
  id: z.string(),
  name: z.string(),
  type: z.string(),
  start_date: z.string(),
  end_date: z.string().nullable(),
  current: z.boolean(),
});

export const zNameform = z.object({
  first_name: z.string(),
  last_name: z.string(),
  gup_person_id: z.string(),
  start_date: z.string(),
  end_date: z.string().nullable(),
  primary: z.boolean(),
});

export const zIdentifier = z.object({
  code: z.string(),
  value: z.string(),
});

export const zAuthor = z.object({
  id: z.string(),
  year_of_birth: z.number(),
  email: z.string().nullable(),
  identifiers: z.array(zIdentifier),
  names: z.array(zNameform),
  departments: z.array(zDepartment),
});

export const zAuthorArray = z.array(zAuthor);
export const zIdentifierArray = z.array(zIdentifier);

export const zAuthorResultList = z.object({
  showing: z.number(),
  total: z.number(),
  data: zAuthorArray,
});

export type Author = z.infer<typeof zAuthor>;
export type Identifier = z.infer<typeof zIdentifier>;
export type AuthorArray = z.infer<typeof zAuthorArray>;
export type IdentifierArray = z.infer<typeof zIdentifierArray>;
export type Department = z.infer<typeof zDepartment>;
export type Nameform = z.infer<typeof zNameform>;
export type AuthorResultList = z.infer<typeof zAuthorResultList>;
