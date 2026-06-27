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
