import type {
  DisputePriority,
  DisputeStatus,
  KycStatus,
  UserRole,
} from "@prisma/client";
import { adminRepository } from "@/lib/repositories/admin.repository";
import type {
  ListDisputesInput,
  ListKycInput,
  ListUsersInput,
} from "@/lib/validators/admin.validator";

export interface AdminStats {
  totalUsers: number;
  activeBookings: number;
  pendingKyc: number;
  monthlyRevenue: number;
}

export interface AdminUserItem {
  id: string;
  phone: string;
  email: string | null;
  roles: UserRole[];
  kycStatus: KycStatus;
  createdAt: string;
}

export interface AdminKycItem {
  id: string;
  userId: string;
  phone: string;
  email: string | null;
  status: KycStatus;
  submittedAt: string;
}

export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

export interface RevenuePoint {
  month: string; // 'YYYY-MM'
  total: number;
}

export interface AdminDisputeItem {
  id: string;
  bookingId: string;
  title: string;
  priority: DisputePriority;
  status: DisputeStatus;
  createdAt: string;
}

function startOfCurrentMonth(now: Date = new Date()): Date {
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

function monthKey(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

export const adminService = {
  async getStats(): Promise<AdminStats> {
    const [totalUsers, activeBookings, pendingKyc, monthlyRevenue] =
      await Promise.all([
        adminRepository.countUsers(),
        adminRepository.countActiveBookings(),
        adminRepository.countPendingKyc(),
        adminRepository.sumRevenueSince(startOfCurrentMonth()),
      ]);
    return { totalUsers, activeBookings, pendingKyc, monthlyRevenue };
  },

  // Chuỗi doanh thu `months` tháng gần nhất (cũ → mới), bù 0 cho tháng trống.
  async getRevenueSeries(months: number): Promise<RevenuePoint[]> {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth() - (months - 1), 1);
    const rows = await adminRepository.monthlyRevenue(start);

    const totals = new Map<string, number>();
    for (const row of rows) {
      totals.set(monthKey(new Date(row.month)), Number(row.total));
    }

    const series: RevenuePoint[] = [];
    for (let i = 0; i < months; i += 1) {
      const d = new Date(now.getFullYear(), now.getMonth() - (months - 1) + i, 1);
      const key = monthKey(d);
      series.push({ month: key, total: totals.get(key) ?? 0 });
    }
    return series;
  },

  async listDisputes(
    input: ListDisputesInput,
  ): Promise<Paginated<AdminDisputeItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findDisputes(
      input.status,
      skip,
      input.limit,
    );
    return {
      items: rows.map((d) => ({
        id: d.id,
        bookingId: d.bookingId,
        title: d.title,
        priority: d.priority,
        status: d.status,
        createdAt: d.createdAt.toISOString(),
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },

  async listUsers(input: ListUsersInput): Promise<Paginated<AdminUserItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findUsers({
      skip,
      take: input.limit,
      role: input.role,
      search: input.search,
    });
    return {
      items: rows.map((u) => ({
        id: u.id,
        phone: u.phone,
        email: u.email,
        roles: u.roles,
        kycStatus: u.kycStatus,
        createdAt: u.createdAt.toISOString(),
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },

  async listKyc(input: ListKycInput): Promise<Paginated<AdminKycItem>> {
    const skip = (input.page - 1) * input.limit;
    const [rows, total] = await adminRepository.findKycQueue(
      input.status,
      skip,
      input.limit,
    );
    return {
      items: rows.map((k) => ({
        id: k.id,
        userId: k.userId,
        phone: k.user.phone,
        email: k.user.email,
        status: k.status,
        submittedAt: k.createdAt.toISOString(),
      })),
      total,
      page: input.page,
      limit: input.limit,
    };
  },
};
