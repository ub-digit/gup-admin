import { z } from "zod";

export const zDepartment = z.object({
  id: z.number(),
  name: z.string(),
  created_at: z.string().nullish(),
  updated_at: z.string().nullish(),
  name_sv: z.string(),
  name_en: z.string(),
  start_year: z.number().nullish(),
  end_year: z.number().nullish(),
  faculty_id: z.number().nullish(),
  parentid: z.nullable(z.number()),
  grandparentid: z.nullable(z.number()),
  created_by: z.string().nullish(),
  updated_by: z.nullable(z.string()),
  staffnotes: z.nullable(z.string()),
  orgdbid: z.nullable(z.string()),
  orgnr: z.string().nullish(),
  is_internal: z.boolean().nullish(),
});
export const zDepartmentArray = z.object({
  data: z.array(zDepartment),
  showing: z.number(),
  total: z.number(),
});

export type Department = z.infer<typeof zDepartment>;

export type DepartmentArray = z.infer<typeof zDepartmentArray>;
