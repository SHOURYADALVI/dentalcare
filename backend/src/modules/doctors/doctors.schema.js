import { z } from 'zod';

export const doctorIdParamSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({
    id: z.string().uuid('Doctor id must be a valid UUID'),
  }),
  query: z.object({}).passthrough(),
});
