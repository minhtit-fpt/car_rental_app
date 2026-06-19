import { ownerRepository } from "@/lib/repositories/owner.repository";

export interface RevenuePoint {
  month: string; // 'YYYY-MM'
  total: number;
}

export interface OwnerTransaction {
  id: string;
  amount: number;
  paidAt: string | null;
  startTime: string;
  endTime: string;
  renterPhone: string;
  renterEmail: string | null;
  vehicleTitle: string;
}

export interface OwnerRevenue {
  monthRevenue: number; // doanh thu tháng hiện tại
  totalTrips: number; // số chuyến đã thanh toán (tháng hiện tại)
  monthly: RevenuePoint[];
  transactions: OwnerTransaction[];
}

const RECENT_TX_LIMIT = 10;

function startOfCurrentMonth(now: Date = new Date()): Date {
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

function monthKey(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

export const ownerService = {
  // Tổng quan doanh thu owner: tháng hiện tại + chuỗi `months` tháng + giao dịch gần đây.
  async getRevenue(ownerId: string, months: number): Promise<OwnerRevenue> {
    const now = new Date();
    const monthStart = startOfCurrentMonth(now);
    const seriesStart = new Date(
      now.getFullYear(),
      now.getMonth() - (months - 1),
      1,
    );

    const [monthRevenue, totalTrips, rows, txRows] = await Promise.all([
      ownerRepository.sumPaidRevenue(ownerId, monthStart),
      ownerRepository.countPaidTrips(ownerId, monthStart),
      ownerRepository.monthlyRevenue(ownerId, seriesStart),
      ownerRepository.recentTransactions(ownerId, RECENT_TX_LIMIT),
    ]);

    const totals = new Map<string, number>();
    for (const row of rows) {
      totals.set(monthKey(new Date(row.month)), Number(row.total));
    }
    const monthly: RevenuePoint[] = [];
    for (let i = 0; i < months; i += 1) {
      const d = new Date(now.getFullYear(), now.getMonth() - (months - 1) + i, 1);
      const key = monthKey(d);
      monthly.push({ month: key, total: totals.get(key) ?? 0 });
    }

    const transactions: OwnerTransaction[] = txRows.map((t) => ({
      id: t.id,
      amount: t.amount,
      paidAt: t.paidAt ? t.paidAt.toISOString() : null,
      startTime: t.startTime.toISOString(),
      endTime: t.endTime.toISOString(),
      renterPhone: t.renterPhone,
      renterEmail: t.renterEmail,
      vehicleTitle: t.vehicleTitle,
    }));

    return { monthRevenue, totalTrips, monthly, transactions };
  },
};
