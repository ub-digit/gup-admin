import { z } from "zod";

export const zDepartment = z.object({
  id: z.number().nullable(),
  created_at: z.string().nullish(),
  updated_at: z.string().nullish(),
  name_sv: z.string(),
  name_en: z.string(),
  start_year: z.number().nullish(),
  end_year: z.number().nullish(),
  faculty_id: z.number().nullish(),
  parentid: z.number().nullish(), // replace with list of hierarchy
  grandparentid: z.number().nullish(), // replace with list of hierarchy
  staffnotes: z.string().nullish(),
  orgdbid: z.string().nullish(),
  orgnr: z.string().nullish(),
  is_internal: z.boolean().nullish(), // checkbox
  is_faculty: z.boolean().nullish(), // checkbox
  hierarchy: z.array(z.number()).nullish(),
});
export const zDepartmentArray = z.object({
  data: z.array(zDepartment),
  showing: z.number(),
  total: z.number(),
});

export type Department = z.infer<typeof zDepartment>;

export type DepartmentArray = z.infer<typeof zDepartmentArray>;
