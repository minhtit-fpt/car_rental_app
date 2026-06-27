/// Cấu hình toàn cục build-time. Không chứa secret (chỉ là endpoint công khai).
class AppConfig {
  const AppConfig._();

  /// Base URL backend Next.js — chỉ là **origin**, KHÔNG kèm `/api` (mọi path
  /// đã tự thêm `/api/...`; nếu kèm vào sẽ bị nhân đôi `/api/api/...`).
  /// Override khi chạy:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000   # Android emulator
  ///   flutter run --dart-define=API_BASE_URL=http://localhost:3000  # iOS sim / macOS / web
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Base URL của AI service (FastAPI chatbot RAG) — origin riêng, KHÔNG kèm path.
  /// Tách khỏi [apiBaseUrl] vì chatbot chạy ở service Python độc lập (mặc định
  /// cổng 8001), trả về text/plain streaming chứ không theo envelope backend.
  /// Override khi chạy:
  ///   flutter run --dart-define=AI_BASE_URL=http://10.0.2.2:8001   # Android emulator
  ///   flutter run --dart-define=AI_BASE_URL=http://localhost:8001  # iOS sim / macOS
  static const String aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'http://localhost:8001',
  );

  /// Origin công khai dùng cho link chia sẻ / deep-link (vd: chia sẻ xe).
  /// Tách khỏi [apiBaseUrl] vì link chia sẻ trỏ tới web/app công khai, không
  /// phải endpoint API. Override khi build:
  ///   flutter run --dart-define=WEB_BASE_URL=https://ridevn.app
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://ridevn.app',
  );
}
