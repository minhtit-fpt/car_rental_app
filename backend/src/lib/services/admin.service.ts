import type { KycStatus, UserRole } from "@prisma/client";
import { adminRepository } from "@/lib/repositories/admin.repository";
import type {
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

function startOfCurrentMonth(now: Date = new Date()): Date {
  return new Date(now.getFullYear(), now.getMonth(), 1);
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
