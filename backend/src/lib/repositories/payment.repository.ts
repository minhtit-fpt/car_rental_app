import { type Payment, type PaymentMethod, type PaymentStatus } from "@prisma/client";
import { prisma } from "@/db/prisma";

// Tầng truy cập DB cho Payment — CHỈ nơi đây gọi Prisma cho bảng Payment.

export interface CreatePaymentData {
  bookingId: string;
  method: PaymentMethod;
  amount: number;
  gatewayRef: string;
}

export interface UpdatePaymentStatusData {
  status: PaymentStatus;
  gatewayRef?: string;
  paidAt?: Date | null;
}

export const paymentRepository = {
  create(data: CreatePaymentData): Promise<Payment> {
    return prisma.payment.create({ data });
  },

  findById(id: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { id } });
  },

  findByBookingId(bookingId: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { bookingId } });
  },

  updateStatus(id: string, data: UpdatePaymentStatusData): Promise<Payment> {
    return prisma.payment.update({ where: { id }, data });
  },
};
