import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const { sendMailMock, createTransportMock } = vi.hoisted(() => {
  const sendMail = vi.fn();
  return {
    sendMailMock: sendMail,
    createTransportMock: vi.fn(() => ({ sendMail })),
  };
});

vi.mock("nodemailer", () => ({
  default: { createTransport: createTransportMock },
}));

import { emailService } from "@/lib/services/email.service";

const SMTP_KEYS = ["SMTP_HOST", "SMTP_PORT", "SMTP_USER", "SMTP_PASS", "SMTP_FROM"];

function clearSmtpEnv(): void {
  for (const key of SMTP_KEYS) delete process.env[key];
}

describe("emailService.sendNotificationEmail", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.resetModules();
    clearSmtpEnv();
  });

  afterEach(() => clearSmtpEnv());

  it("no-ops and returns false when SMTP is not configured", async () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});

    const sent = await emailService.sendNotificationEmail("a@b.com", "Hi", null);

    expect(sent).toBe(false);
    expect(sendMailMock).not.toHaveBeenCalled();
    warnSpy.mockRestore();
  });
});

describe("emailService.sendBookingEmail", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.resetModules();
    clearSmtpEnv();
  });

  afterEach(() => clearSmtpEnv());

  it("renders escaped booking details (vehicle, dates, price, refund, id)", async () => {
    process.env.SMTP_HOST = "smtp.test";
    process.env.SMTP_USER = "u";
    process.env.SMTP_PASS = "p";
    process.env.SMTP_FROM = "no-reply@ridevn.vn";
    const { emailService: svc } = await import("@/lib/services/email.service");
    sendMailMock.mockResolvedValue({});

    const sent = await svc.sendBookingEmail(
      "a@b.com",
      "Thanh toán thành công — RideVN",
      "Đơn của bạn đã được thanh toán.",
      {
        bookingId: "book-1",
        vehicleTitle: "VinFast <VF8>",
        startTime: new Date("2026-07-20T09:00:00Z"),
        endTime: new Date("2026-07-22T09:00:00Z"),
        totalPrice: 1_500_000,
        refundAmount: 500_000,
      },
    );

    expect(sent).toBe(true);
    const html = sendMailMock.mock.calls[0][0].html as string;
    expect(html).toContain("VinFast &lt;VF8&gt;"); // escaped
    expect(html).toContain("1.500.000₫");
    expect(html).toContain("Số tiền hoàn");
    expect(html).toContain("500.000₫");
    expect(html).toContain("book-1");
    expect(html).toContain("Nhận xe");
    expect(html).toContain("Trả xe");
  });
});
