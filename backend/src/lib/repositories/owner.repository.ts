import { Prisma } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho các tổng hợp của OWNER (doanh thu trên các xe của họ).
// Doanh thu = Payment PAID của Booking thuộc Vehicle có ownerId tương ứng.

export interface OwnerTransactionRow {
  id: string;
  amount: number;
  paidAt: Date | null;
  startTime: Date;
  endTime: Date;
  renterPhone: string;
  renterEmail: string | null;
  vehicleTitle: string;
}

const PAID_OWNED = (ownerId: string): Prisma.PaymentWhereInput => ({
  status: "PAID",
  booking: { vehicle: { ownerId } },
});

export const ownerRepository = {
  async sumPaidRevenue(ownerId: string, since?: Date): Promise<number> {
    const result = await prisma.payment.aggregate({
      _sum: { amount: true },
      where: {
        ...PAID_OWNED(ownerId),
        ...(since && { paidAt: { gte: since } }),
      },
    });
    return result._sum.amount?.toNumber() ?? 0;
  },

  countPaidTrips(ownerId: string, since?: Date): Promise<number> {
    return prisma.payment.count({
      where: {
        ...PAID_OWNED(ownerId),
        ...(since && { paidAt: { gte: since } }),
      },
    });
  },

  // Doanh thu PAID gộp theo tháng cho các xe của owner kể từ `since`.
  monthlyRevenue(
    ownerId: string,
    since: Date,
  ): Promise<{ month: Date; total: number }[]> {
    return prisma.$queryRaw<{ month: Date; total: number }[]>`
      SELECT date_trunc('month', p."paidAt") AS month,
             COALESCE(SUM(p."amount"), 0)::float8 AS total
      FROM "Payment" p
      JOIN "Booking" b ON b."id" = p."bookingId"
      JOIN "Vehicle" v ON v."id" = b."vehicleId"
      WHERE p."status" = 'PAID'
        AND p."paidAt" >= ${since}
        AND v."ownerId" = ${ownerId}::uuid
      GROUP BY 1
      ORDER BY 1 ASC
    `;
  },

  async recentTransactions(
    ownerId: string,
    limit: number,
  ): Promise<OwnerTransactionRow[]> {
    const rows = await prisma.payment.findMany({
      where: PAID_OWNED(ownerId),
      orderBy: { paidAt: "desc" },
      take: limit,
      select: {
        id: true,
        amount: true,
        paidAt: true,
        booking: {
          select: {
            startTime: true,
            endTime: true,
            renter: { select: { phone: true, email: true } },
            vehicle: { select: { title: true } },
          },
        },
      },
    });
    return rows.map((r) => ({
      id: r.id,
      amount: r.amount.toNumber(),
      paidAt: r.paidAt,
      startTime: r.booking.startTime,
      endTime: r.booking.endTime,
      renterPhone: r.booking.renter.phone,
      renterEmail: r.booking.renter.email,
      vehicleTitle: r.booking.vehicle.title,
    }));
  },
};
