import { describe, expect, it } from "vitest";
import { hashPassword, verifyPassword } from "@/lib/auth/password";

describe("password", () => {
  it("hashes and verifies a correct password", async () => {
    const hash = await hashPassword("S3curePass!");

    expect(hash).not.toBe("S3curePass!");
    expect(await verifyPassword("S3curePass!", hash)).toBe(true);
  });

  it("rejects a wrong password", async () => {
    const hash = await hashPassword("S3curePass!");

    expect(await verifyPassword("wrong-pass", hash)).toBe(false);
  });

  it("produces different hashes for the same input (salted)", async () => {
    const a = await hashPassword("samePass123");
    const b = await hashPassword("samePass123");

    expect(a).not.toBe(b);
  });
});
