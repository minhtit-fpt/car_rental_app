import { z } from "zod";
import { BookingStatus } from "@prisma/client";

// Zod schemas cho Booking. Thời gian nhận dạng ISO 8601 (cho phép cả 'Z' lẫn offset).

const isoDateTime = z.string().datetime({ offset: true });

export const createBookingSchema = z
  .object({
    vehicleId: z.string().uuid("vehicleId không hợp lệ"),
    startTime: isoDateTime,
    endTime: isoDateTime,
    deliveryRequested: z.boolean().default(false),
  })
  .refine((v) => new Date(v.endTime) > new Date(v.startTime), {
    message: "endTime phải sau startTime",
    path: ["endTime"],
  });

export const listBookingsQuerySchema = z.object({
  status: z.nativeEnum(BookingStatus).optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type CreateBookingInput = z.infer<typeof createBookingSchema>;
export type ListBookingsQuery = z.infer<typeof listBookingsQuerySchema>;
