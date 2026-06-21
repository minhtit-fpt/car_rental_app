import { z } from "zod";

// Zod schema cho Favorite. vehicleId đến từ path param /api/favorites/[vehicleId].

export const vehicleIdParamSchema = z
  .string()
  .uuid("vehicleId không hợp lệ");

export type VehicleIdParam = z.infer<typeof vehicleIdParamSchema>;
