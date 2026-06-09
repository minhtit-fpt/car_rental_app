import bcrypt from "bcryptjs";

// Băm mật khẩu bằng bcrypt. Pure-JS nên chạy được trên serverless/Edge build.
const SALT_ROUNDS = 12;

export async function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, SALT_ROUNDS);
}

export async function verifyPassword(
  plain: string,
  hash: string,
): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}
