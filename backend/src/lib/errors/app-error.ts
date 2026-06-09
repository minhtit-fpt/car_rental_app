// Lỗi nghiệp vụ có status + code để route handler map sang HTTP response chuẩn.
export class AppError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "AppError";
  }
}
