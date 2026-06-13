import { BookingStatus, Prisma, type Review } from "@prisma/client";
import { AppError } from "@/lib/errors/app-error";
import { bookingRepository } from "@/lib/repositories/booking.repository";
import { reviewRepository } from "@/lib/repositories/review.repository";
import { vehicleRepository } from "@/lib/repositories/vehicle.repository";
import type {
  CreateReviewInput,
  ListReviewsQuery,
} from "@/lib/validators/review.validator";

export interface PublicReview {
  id: string;
  bookingId: string;
  reviewerId: string;
  targetId: string;
  rating: number;
  comment: string | null;
  createdAt: Date;
}

export interface ReviewListResult {
  items: PublicReview[];
  total: number;
  average: number;
  page: number;
  limit: number;
}

// Chỉ cho đánh giá khi chuyến đã bắt đầu/hoàn tất (đã thanh toán xác nhận).
const REVIEWABLE: BookingStatus[] = [
  BookingStatus.CONFIRMED,
  BookingStatus.IN_PROGRESS,
  BookingStatus.COMPLETED,
];

function toPublicReview(r: Review): PublicReview {
  return {
    id: r.id,
    bookingId: r.bookingId,
    reviewerId: r.reviewerId,
    targetId: r.targetId,
    rating: r.rating,
    comment: r.comment,
    createdAt: r.createdAt,
  };
}

export const reviewService = {
  // Người đánh giá là renter → target là chủ xe; là chủ xe → target là renter.
  async create(
    reviewerId: string,
    input: CreateReviewInput,
  ): Promise<PublicReview> {
    const booking = await bookingRepository.findById(input.bookingId);
    if (!booking) {
      throw new AppError(404, "BOOKING_NOT_FOUND", "Không tìm thấy đơn đặt");
    }
    if (!REVIEWABLE.includes(booking.status)) {
      throw new AppError(
        409,
        "REVIEW_NOT_ALLOWED",
        "Chỉ có thể đánh giá sau khi đơn được xác nhận",
      );
    }

    const vehicle = await vehicleRepository.findById(booking.vehicleId);
    if (!vehicle) {
      throw new AppError(404, "VEHICLE_NOT_FOUND", "Không tìm thấy xe");
    }

    let targetId: string;
    if (booking.renterId === reviewerId) {
      targetId = vehicle.ownerId;
    } else if (vehicle.ownerId === reviewerId) {
      targetId = booking.renterId;
    } else {
      throw new AppError(403, "FORBIDDEN", "Bạn không thuộc đơn đặt này");
    }

    try {
      const review = await reviewRepository.create({
        bookingId: input.bookingId,
        reviewerId,
        targetId,
        rating: input.rating,
        comment: input.comment,
      });
      return toPublicReview(review);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        throw new AppError(409, "ALREADY_REVIEWED", "Bạn đã đánh giá đơn này");
      }
      throw error;
    }
  },

  async listForTarget(
    targetId: string,
    query: ListReviewsQuery,
  ): Promise<ReviewListResult> {
    const [{ items, total }, summary] = await Promise.all([
      reviewRepository.findManyByTarget({ targetId, ...query }),
      reviewRepository.summaryForTarget(targetId),
    ]);
    return {
      items: items.map(toPublicReview),
      total,
      average: summary.average,
      page: query.page,
      limit: query.limit,
    };
  },
};
