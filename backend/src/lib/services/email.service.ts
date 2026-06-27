import nodemailer, { type Transporter } from "nodemailer";

// Gửi email qua SMTP (Nodemailer). Nếu thiếu cấu hình SMTP_* → no-op + log,
// để môi trường dev không có SMTP vẫn chạy bình thường.

interface Mailer {
  transporter: Transporter;
  from: string;
}

// `undefined` = chưa khởi tạo, `null` = đã xác định là không cấu hình.
let cached: Mailer | null | undefined;

function buildMailer(): Mailer | null {
  const host = process.env.SMTP_HOST;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  const from = process.env.SMTP_FROM ?? user;
  if (!host || !user || !pass || !from) return null;

  const port = Number(process.env.SMTP_PORT ?? "587");
  const transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
  });
  return { transporter, from };
}

function getMailer(): Mailer | null {
  if (cached === undefined) cached = buildMailer();
  return cached;
}

function renderHtml(title: string, body: string | null): string {
  const safeTitle = escapeHtml(title);
  const safeBody = body ? escapeHtml(body) : "";
  return `<div style="font-family:Arial,Helvetica,sans-serif;max-width:480px;margin:0 auto;padding:24px;color:#10131A">
    <div style="font-size:18px;font-weight:700;color:#14336B">RideVN</div>
    <h2 style="font-size:18px;margin:16px 0 8px">${safeTitle}</h2>
    ${safeBody ? `<p style="font-size:14px;line-height:1.6;color:#4A5263">${safeBody}</p>` : ""}
    <hr style="border:none;border-top:1px solid #DDE3EC;margin:24px 0" />
    <p style="font-size:12px;color:#6B7384">Đây là email tự động từ RideVN, vui lòng không trả lời.</p>
  </div>`;
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

export const emailService = {
  // Gửi 1 email thông báo. Không bao giờ ném lỗi — trả false nếu bỏ qua/thất bại.
  async sendNotificationEmail(
    to: string,
    subject: string,
    body: string | null,
  ): Promise<boolean> {
    const mailer = getMailer();
    if (!mailer) {
      console.warn("[email] SMTP chưa cấu hình — bỏ qua gửi email.");
      return false;
    }
    try {
      await mailer.transporter.sendMail({
        from: mailer.from,
        to,
        subject,
        html: renderHtml(subject, body),
      });
      return true;
    } catch (error) {
      console.error("[email] Gửi email thất bại:", error);
      return false;
    }
  },
};
