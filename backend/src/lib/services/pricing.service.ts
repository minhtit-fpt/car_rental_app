// Dynamic pricing service — dựng báo giá CÓ GIẢI THÍCH cho một lượt thuê.
//
// `quote()` là pure (chỉ tính toán) để booking.service và API preview dùng
// chung. `quoteForVehicle()` nạp giá gốc từ DB (chủ xe đặt) rồi gọi quote —
// đây là điểm nối cho tool-calling chatbot (B5) về sau.
//
// Quy ước: giá gốc LẤY TỪ DB (pricePerDay), KHÔNG nhúng vào RAG.

import { AppError } from "@/lib/errors/app-error";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import {
  applyFactors,
  buildSurgeFactors,
  computeRentalDays,
  type PriceFactor,
} from "@/lib/utils/surge.util";

const CURRENCY = "VND";

export interface QuoteInput {
  pricePerDay: number;
  startTime: Date;
  endTime: Date;
  // Hệ số cung/cầu khu vực (1 = trung tính). Để ngỏ cho LightGBM/heuristic sau.
  demandMultiplier?: number;
  holidays?: ReadonlySet<string>;
}

export interface QuoteForVehicleInput {
  vehicleId: string;
  startTime: Date;
  endTime: Date;
  demandMultiplier?: number;
  holidays?: ReadonlySet<string>;
}

export interface PriceQuote {
  basePricePerDay: number;
  days: number;
  basePrice: number; // basePricePerDay × days (trước surge)
  factors: PriceFactor[]; // các yếu tố đang áp dụng, để FE giải thích
  finalPrice: number; // sau khi nhân tất cả bội số, làm tròn VND
  currency: string;
}

export const pricingService = {
  // Tính báo giá thuần từ giá gốc + khoảng thời gian. Không chạm DB.
  quote(input: QuoteInput): PriceQuote {
    const days = computeRentalDays(input.startTime, input.endTime);
    const basePrice = input.pricePerDay * days;
    const factors = buildSurgeFactors({
      startTime: input.startTime,
      days,
      demandMultiplier: input.demandMultiplier,
      holidays: input.holidays,
    });
    const finalPrice = applyFactors(basePrice, factors);
    return {
      basePricePerDay: input.pricePerDay,
      days,
      basePrice,
      factors,
      finalPrice,
      currency: CURRENCY,
    };
  },

  // Nạp giá gốc của xe từ DB rồi báo giá. 404 nếu xe không tồn tại.
  async quoteForVehicle(input: QuoteForVehicleInput): Promise<PriceQuote> {
    const vehicle = await vehicleRepository.findById(input.vehicleId);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }
    return this.quote({
      pricePerDay: Number(vehicle.pricePerDay),
      startTime: input.startTime,
      endTime: input.endTime,
      demandMultiplier: input.demandMultiplier,
      holidays: input.holidays,
    });
  },
};
