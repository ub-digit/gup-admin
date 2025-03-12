import { z } from "zod";

export const zDepartment = z.object({
  gup_department_id: z.string().nullish(),
  name: z.string().nullish(),
  type: z.string().nullish(),
  start_date: z.string().nullish(),
  end_date: z.string().nullish(),
  current: z.boolean().optional(),
});

export const zNameform = z.object({
  first_name: z.string(),
  last_name: z.string(),
  full_name: z.string().nullish(),
  gup_person_id: z.number().nullish(),
  start_date: z.string().nullish(),
  end_date: z.string().nullish(),
  primary: z.boolean().optional(),
});

export const zIdentifier = z.object({
  code: z.string(),
  value: z.string().nullable(),
});

export const zAuthor = z.object({
  id: z.number().nullable(),
  year_of_birth: z.number().nullish(),
  email: z.string().nullish(),
  identifiers: z.array(zIdentifier),
  names: z.array(zNameform),
  departments: z.array(zDepartment),
  created_at: z.string().nullish(),
  updated_at: z.string().nullish(),
});

export const zAuthorArray = z.array(zAuthor);
export const zIdentifierArray = z.array(zIdentifier);
export const zDepartmentArray = z.array(zDepartment);

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
