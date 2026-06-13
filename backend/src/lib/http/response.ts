import { NextResponse } from "next/server";
import { ZodError } from "zod";
import { AppError } from "@/lib/errors/app-error";

// Envelope response chuẩn: { success, data } / { success, error, code }.

interface SuccessBody<T> {
  success: true;
  data: T;
}

interface ErrorBody {
  success: false;
  error: string;
  code: string;
}

export function ok<T>(data: T, status = 200): NextResponse<SuccessBody<T>> {
  return NextResponse.json({ success: true, data }, { status });
}

export function created<T>(data: T): NextResponse<SuccessBody<T>> {
  return ok(data, 201);
}

export function fail(
  message: string,
  code: string,
  status: number,
): NextResponse<ErrorBody> {
  return NextResponse.json(
    { success: false, error: message, code },
    { status },
  );
}

export function toErrorResponse(error: unknown): NextResponse<ErrorBody> {
  if (error instanceof AppError) {
    return fail(error.message, error.code, error.status);
  }
  if (error instanceof ZodError) {
    const message = error.issues[0]?.message ?? "Dữ liệu không hợp lệ";
    return fail(message, "VALIDATION_ERROR", 400);
  }
  // Không lộ chi tiết lỗi nội bộ cho client.
  console.error("Unhandled route error:", error);
  return fail("Lỗi máy chủ", "INTERNAL_ERROR", 500);
}
