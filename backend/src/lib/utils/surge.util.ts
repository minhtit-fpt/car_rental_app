// Dynamic pricing — engine surge nhiều yếu tố, CÓ GIẢI THÍCH.
//
// Triết lý: finalPrice = basePrice × Π(factor_i). Mỗi yếu tố là một bội số
// (multiplier) đi kèm nhãn để FE hiển thị và để bảo vệ vẽ biểu đồ. Tất cả hàm
// ở đây là PURE (không chạm DB) để dễ test; phần lấy dữ liệu động (cung/cầu)
// được tính ở pricing.service rồi truyền vào qua `demandMultiplier`.
//
// Mọi yếu tố thời gian được đánh giá theo giờ Việt Nam (UTC+7, không có DST).

const MS_PER_HOUR = 3_600_000;
const MS_PER_DAY = 24 * MS_PER_HOUR;
const VN_OFFSET_MS = 7 * MS_PER_HOUR;

// Bội số từng yếu tố — đặt tên hằng, không rải magic number.
// Xe cho thuê theo NGÀY nên không còn hệ số "giờ cao điểm".
const WEEKEND_MULTIPLIER = 1.2;
const HOLIDAY_MULTIPLIER = 1.3;

// Giảm giá theo thời lượng thuê (thuê càng dài, đơn giá càng mềm).
const DURATION_DISCOUNTS: ReadonlyArray<{ minDays: number; multiplier: number }> =
  [
    { minDays: 7, multiplier: 0.8 }, // ≥ 1 tuần
    { minDays: 3, multiplier: 0.85 }, // ≥ 3 ngày
  ];

// Biên an toàn cho hệ số cung/cầu để 1 cú sốc dữ liệu không thổi giá vô lý.
const DEMAND_MIN_MULTIPLIER = 0.8;
const DEMAND_MAX_MULTIPLIER = 1.5;

// Lễ cố định theo dương lịch (MM-DD). Tết Âm lịch đổi theo năm → truyền thêm
// qua `holidays` nếu cần, không hardcode ở đây.
export const DEFAULT_HOLIDAYS: ReadonlySet<string> = new Set([
  "01-01", // Tết Dương lịch
  "04-30", // Giải phóng miền Nam
  "05-01", // Quốc tế Lao động
  "09-02", // Quốc khánh
]);

export interface PriceFactor {
  code: string;
  label: string;
  multiplier: number;
}

export interface SurgeInput {
  startTime: Date;
  days: number;
  // Hệ số cung/cầu khu vực (1 = trung tính). Tính ở service rồi truyền vào.
  demandMultiplier?: number;
  // Bộ ngày lễ bổ sung (MM-DD), mặc định DEFAULT_HOLIDAYS.
  holidays?: ReadonlySet<string>;
}

interface VnParts {
  weekday: number; // 0 = Chủ nhật ... 6 = Thứ bảy
  monthDay: string; // "MM-DD"
}

// Đọc các thành phần lịch theo giờ VN bằng cách dịch +7h rồi đọc UTC.
function toVnParts(date: Date): VnParts {
  const shifted = new Date(date.getTime() + VN_OFFSET_MS);
  const month = String(shifted.getUTCMonth() + 1).padStart(2, "0");
  const day = String(shifted.getUTCDate()).padStart(2, "0");
  return {
    weekday: shifted.getUTCDay(),
    monthDay: `${month}-${day}`,
  };
}

// Làm tròn LÊN theo ngày, tối thiểu 1 ngày (thuê cùng ngày = 1 ngày).
export function computeRentalDays(start: Date, end: Date): number {
  return Math.max(1, Math.ceil((end.getTime() - start.getTime()) / MS_PER_DAY));
}

function isWeekend(weekday: number): boolean {
  return weekday === 0 || weekday === 6;
}

function clampDemand(multiplier: number): number {
  return Math.min(
    DEMAND_MAX_MULTIPLIER,
    Math.max(DEMAND_MIN_MULTIPLIER, multiplier),
  );
}

function durationMultiplier(days: number): number | null {
  const tier = DURATION_DISCOUNTS.find((t) => days >= t.minDays);
  return tier ? tier.multiplier : null;
}

// Dựng danh sách yếu tố ĐANG ÁP DỤNG (bỏ qua yếu tố trung tính multiplier=1).
export function buildSurgeFactors(input: SurgeInput): PriceFactor[] {
  const { startTime, days } = input;
  const holidays = input.holidays ?? DEFAULT_HOLIDAYS;
  const parts = toVnParts(startTime);
  const factors: PriceFactor[] = [];

  // Lễ ưu tiên cao hơn cuối tuần; cả hai có thể cùng áp.
  if (holidays.has(parts.monthDay)) {
    factors.push({
      code: "HOLIDAY",
      label: "Ngày lễ",
      multiplier: HOLIDAY_MULTIPLIER,
    });
  } else if (isWeekend(parts.weekday)) {
    factors.push({
      code: "WEEKEND",
      label: "Cuối tuần",
      multiplier: WEEKEND_MULTIPLIER,
    });
  }

  const discount = durationMultiplier(days);
  if (discount !== null) {
    factors.push({
      code: "DURATION_DISCOUNT",
      label: "Giảm giá thuê dài",
      multiplier: discount,
    });
  }

  if (input.demandMultiplier !== undefined) {
    const demand = clampDemand(input.demandMultiplier);
    if (demand !== 1) {
      factors.push({
        code: "DEMAND",
        label: "Nhu cầu khu vực",
        multiplier: demand,
      });
    }
  }

  return factors;
}

// Nhân giá gốc với tích các bội số, làm tròn về số nguyên VND.
export function applyFactors(
  basePrice: number,
  factors: ReadonlyArray<PriceFactor>,
): number {
  const product = factors.reduce((acc, f) => acc * f.multiplier, 1);
  return Math.round(basePrice * product);
}
