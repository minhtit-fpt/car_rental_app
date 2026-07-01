import { z } from "zod";
import { AppError } from "@/lib/errors/app-error";
import { adminService, type AdminMetrics } from "@/lib/services/admin.service";
import {
  llmClient,
  parseJsonFromText,
  type ChatTurn,
} from "@/lib/ai/llm.client";

// Phase 5a — NL-analytics. KHÔNG text-to-SQL. LLM chỉ ánh xạ câu hỏi → 1 template
// query có sẵn (chính là các aggregation Phase 1 trong getMetrics) + ta format
// câu trả lời text. Câu hỏi không khớp → "không hỗ trợ". LM Studio offline →
// thông báo offline. Phòng thủ: tập template đóng, không sinh truy vấn động.

const TEMPLATES = {
  totals: "Tổng quan: số người dùng, số xe, tổng số đơn",
  revenue_by_method: "Doanh thu theo phương thức thanh toán",
  bookings_by_status: "Số đơn theo từng trạng thái",
  fleet_by_type: "Đội xe theo loại + số xe điện",
  top_vehicles: "Top xe theo doanh thu / số chuyến",
  completion_rate: "Tỉ lệ hoàn tất và tỉ lệ huỷ đơn",
  avg_rating: "Điểm đánh giá trung bình",
  recent_bookings: "Các đơn mới nhất",
} as const;

type TemplateKey = keyof typeof TEMPLATES;

export interface AnalyticsAnswer {
  templateKey: TemplateKey | null;
  answer: string;
  // Lát cắt dữ liệu liên quan để FE tái dùng widget Phase 1 nếu muốn.
  data: unknown;
}

const classifySchema = z.object({
  key: z.string(),
});

function fmtMoney(n: number): string {
  return `${Math.round(n).toLocaleString("vi-VN")}đ`;
}
function fmtPct(n: number): string {
  return `${(n * 100).toFixed(1)}%`;
}

// Soạn câu trả lời text + lát dữ liệu từ metrics theo template đã chọn.
function render(key: TemplateKey, m: AdminMetrics): AnalyticsAnswer {
  switch (key) {
    case "totals":
      return {
        templateKey: key,
        answer: `Hiện có ${m.kpi.totalUsers} người dùng, ${m.kpi.totalVehicles} xe (${m.kpi.availableVehicles} sẵn sàng, ${m.kpi.electricVehicles} xe điện) và ${m.kpi.totalBookings} đơn.`,
        data: m.kpi,
      };
    case "revenue_by_method": {
      const total = m.paymentsByMethod.reduce((s, p) => s + p.total, 0);
      const lines = m.paymentsByMethod
        .map((p) => `${p.method}: ${fmtMoney(p.total)}`)
        .join(", ");
      return {
        templateKey: key,
        answer: `Tổng doanh thu ${fmtMoney(total)}${lines ? ` — ${lines}.` : "."}`,
        data: m.paymentsByMethod,
      };
    }
    case "bookings_by_status": {
      const lines = m.bookingsByStatus
        .map((b) => `${b.status}: ${b.count}`)
        .join(", ");
      return {
        templateKey: key,
        answer: `Đơn theo trạng thái — ${lines || "chưa có đơn"}.`,
        data: m.bookingsByStatus,
      };
    }
    case "fleet_by_type": {
      const lines = m.vehiclesByType
        .map((v) => `${v.type}: ${v.count} (EV ${v.electric})`)
        .join(", ");
      return {
        templateKey: key,
        answer: `Đội xe — ${lines || "chưa có xe"}.`,
        data: m.vehiclesByType,
      };
    }
    case "top_vehicles": {
      const lines = m.topVehicles
        .map((v, i) => `${i + 1}. ${v.title} (${fmtMoney(v.revenue)}, ${v.trips} chuyến)`)
        .join("; ");
      return {
        templateKey: key,
        answer: `Top xe theo doanh thu — ${lines || "chưa có dữ liệu"}.`,
        data: m.topVehicles,
      };
    }
    case "completion_rate":
      return {
        templateKey: key,
        answer: `Tỉ lệ hoàn tất ${fmtPct(m.kpi.completionRate)}, tỉ lệ huỷ ${fmtPct(m.kpi.cancellationRate)}.`,
        data: {
          completionRate: m.kpi.completionRate,
          cancellationRate: m.kpi.cancellationRate,
        },
      };
    case "avg_rating":
      return {
        templateKey: key,
        answer: `Điểm đánh giá trung bình: ${m.kpi.avgRating.toFixed(2)}/5.`,
        data: { avgRating: m.kpi.avgRating },
      };
    case "recent_bookings": {
      const lines = m.recentBookings
        .slice(0, 5)
        .map((b) => `${b.vehicleTitle} — ${b.status} (${fmtMoney(b.totalPrice)})`)
        .join("; ");
      return {
        templateKey: key,
        answer: `Đơn mới nhất — ${lines || "chưa có đơn"}.`,
        data: m.recentBookings,
      };
    }
  }
}

const SYSTEM_PROMPT = `Bạn ánh xạ câu hỏi của admin về số liệu nền tảng thuê xe
vào ĐÚNG MỘT khoá template trong danh sách. Nếu không khớp khoá nào, trả "none".
Các khoá:
${Object.entries(TEMPLATES)
  .map(([k, v]) => `- ${k}: ${v}`)
  .join("\n")}

CHỈ trả về JSON: {"key": "<một_khoá_hoặc_none>"}`;

export const analyticsService = {
  async ask(question: string): Promise<AnalyticsAnswer> {
    const messages: ChatTurn[] = [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: question },
    ];

    let key: string;
    try {
      const raw = await llmClient.chat(messages);
      key = classifySchema.parse(parseJsonFromText(raw)).key;
    } catch (error) {
      if (error instanceof AppError && error.status === 503) {
        return {
          templateKey: null,
          answer: "Dịch vụ AI đang offline, chưa thể phân tích câu hỏi.",
          data: null,
        };
      }
      throw error;
    }

    if (!(key in TEMPLATES)) {
      return {
        templateKey: null,
        answer:
          "Câu hỏi này chưa được hỗ trợ. Hãy hỏi về doanh thu, số đơn, đội xe, top xe, tỉ lệ hoàn tất/huỷ, đánh giá hoặc đơn mới nhất.",
        data: null,
      };
    }

    const metrics = await adminService.getMetrics();
    return render(key as TemplateKey, metrics);
  },
};
