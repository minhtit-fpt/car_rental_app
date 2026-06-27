import { z } from "zod";
import { VehicleType } from "@prisma/client";

// Zod schemas cho Vehicle. Query string dùng z.coerce; body JSON dùng kiểu thật.

const vehicleTypeSchema = z.nativeEnum(VehicleType);

// Query bool an toàn: chỉ "true"/"false" (tránh z.coerce.boolean biến "false"→true).
const boolQuery = z.enum(["true", "false"]).transform((v) => v === "true");

const latField = z.coerce.number().min(-90).max(90);
const lngField = z.coerce.number().min(-180).max(180);

export const listVehiclesQuerySchema = z.object({
  type: vehicleTypeSchema.optional(),
  isElectric: boolQuery.optional(),
  available: boolQuery.optional(),
  minPrice: z.coerce.number().nonnegative().optional(),
  maxPrice: z.coerce.number().nonnegative().optional(),
  // mine=true → chỉ trả xe của người gọi (cần đăng nhập), xử lý ở route handler.
  mine: boolQuery.optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

// Cửa sổ thời gian truy vấn lịch bận của một xe (mặc định từ hôm nay).
export const availabilityQuerySchema = z.object({
  from: z.string().datetime({ offset: true }).optional(),
  to: z.string().datetime({ offset: true }).optional(),
});

export const nearbyQuerySchema = z.object({
  lat: latField,
  lng: lngField,
  radius: z.coerce.number().positive().max(50000).default(5000),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

const transmissionSchema = z.enum(["AUTOMATIC", "MANUAL"]);

export const createVehicleSchema = z.object({
  type: vehicleTypeSchema,
  title: z.string().trim().min(1, "Tiêu đề là bắt buộc").max(120),
  pricePerHour: z.number().positive("Giá thuê phải lớn hơn 0").max(100000000),
  isElectric: z.boolean().default(false),
  deliveryAvailable: z.boolean().default(false),
  isAvailable: z.boolean().default(true),
  seats: z.number().int().positive().max(64).optional(),
  doors: z.number().int().positive().max(10).optional(),
  transmission: transmissionSchema.optional(),
  city: z.string().trim().min(1).max(100).optional(),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
});

export const updateVehicleSchema = z
  .object({
    title: z.string().trim().min(1).max(120).optional(),
    pricePerHour: z.number().positive().max(100000000).optional(),
    isElectric: z.boolean().optional(),
    deliveryAvailable: z.boolean().optional(),
    isAvailable: z.boolean().optional(),
    seats: z.number().int().positive().max(64).optional(),
    doors: z.number().int().positive().max(10).optional(),
    transmission: transmissionSchema.optional(),
    city: z.string().trim().min(1).max(100).optional(),
    lat: z.number().min(-90).max(90).optional(),
    lng: z.number().min(-180).max(180).optional(),
  })
  .refine((v) => Object.keys(v).length > 0, {
    message: "Không có trường nào để cập nhật",
  })
  // lat/lng phải đi theo cặp để cập nhật vị trí.
  .refine((v) => (v.lat === undefined) === (v.lng === undefined), {
    message: "lat và lng phải đi cùng nhau",
    path: ["lat"],
  });

export type ListVehiclesQuery = z.infer<typeof listVehiclesQuerySchema>;
export type AvailabilityQuery = z.infer<typeof availabilityQuerySchema>;
export type NearbyQuery = z.infer<typeof nearbyQuerySchema>;
export type CreateVehicleInput = z.infer<typeof createVehicleSchema>;
export type UpdateVehicleInput = z.infer<typeof updateVehicleSchema>;
