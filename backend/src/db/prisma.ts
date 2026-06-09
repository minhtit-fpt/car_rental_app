import { PrismaClient } from "@prisma/client";

// Prisma client singleton — tránh tạo nhiều kết nối khi hot-reload dev.
// Dùng client này ở tầng repository, KHÔNG gọi trực tiếp từ route/service.

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
