// Chuẩn hóa số điện thoại di động VN về E.164 (+84xxxxxxxxx).
// Chấp nhận: 0xxxxxxxxx, 84xxxxxxxxx, +84xxxxxxxxx (có thể chứa space/dash).
// Trả về null nếu không hợp lệ. Đầu số di động VN: 3, 5, 7, 8, 9.

export function normalizeVietnamPhone(input: string): string | null {
  const digits = input.replace(/[\s.\-()]/g, "");

  let national: string;
  if (/^0\d{9}$/.test(digits)) {
    national = digits.slice(1);
  } else if (/^\+84\d{9}$/.test(digits)) {
    national = digits.slice(3);
  } else if (/^84\d{9}$/.test(digits)) {
    national = digits.slice(2);
  } else {
    return null;
  }

  if (!/^[35789]\d{8}$/.test(national)) {
    return null;
  }

  return `+84${national}`;
}
