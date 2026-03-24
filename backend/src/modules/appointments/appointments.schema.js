import { z } from 'zod';

const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)(:[0-5]\d)?$/;

export const bookAppointmentSchema = z.object({
  body: z.object({
    doctor_id: z.string().uuid('doctor_id must be a valid UUID'),
    date: z.string().date('date must be in YYYY-MM-DD format'),
    time: z.string().regex(timeRegex, 'time must be in HH:MM or HH:MM:SS format'),
    consultation_fee: z.number().nonnegative('consultation_fee must be >= 0'),
  }),
  params: z.object({}).passthrough(),
  query: z.object({}).passthrough(),
});
