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
}
