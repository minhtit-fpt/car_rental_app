import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_palette.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

/// Mở cổng thanh toán VNPay trong WebView và bắt URL return.
///
/// VNPay redirect về `vnp_ReturnUrl` kèm các tham số `vnp_*` (gồm
/// `vnp_ResponseCode` và `vnp_SecureHash`). Ta chặn điều hướng đó, bóc tham số
/// và `pop` trả về cho màn thanh toán để gửi backend xác thực.
///
/// Trả về:
///   - `Map<String,String>` các tham số vnp_* khi cổng redirect về return URL.
///   - `null` khi người dùng tự đóng (huỷ).
class VnpayWebViewScreen extends StatefulWidget {
  const VnpayWebViewScreen({super.key, required this.payUrl});

  final String payUrl;

  @override
  State<VnpayWebViewScreen> createState() => _VnpayWebViewScreenState();
}

class _VnpayWebViewScreenState extends State<VnpayWebViewScreen> {
  bool _returned = false;
  double _progress = 0;

  /// Lỗi tải trang cổng (main frame) — hiển thị thay vì để WebView trắng.
  String? _loadError;

  /// Chỉ chấp nhận cert không xác thực được cho đúng host sandbox VNPay:
  /// chain của sandbox ký tới root Sectigo E46 mà Android cũ (≤12) chưa có
  /// trong trust store → ERR_CERT_AUTHORITY_INVALID → trang trắng. Sandbox
  /// chỉ dùng tiền test nên rủi ro chấp nhận được; cổng live KHÔNG được phép.
  static const _trustedSandboxHost = 'sandbox.vnpayment.vn';

  // Đã tới URL return chưa? Nhận diện qua sự hiện diện của vnp_ResponseCode —
  // bền vững dù host return URL được cấu hình khác nhau.
  Map<String, String>? _extractReturnParams(Uri uri) {
    if (!uri.queryParameters.containsKey('vnp_ResponseCode')) return null;
    return Map<String, String>.from(uri.queryParameters);
  }

  void _finishWith(Map<String, String> params) {
    if (_returned) return;
    _returned = true;
    Navigator.of(context).pop(params);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Khi pop bằng nút back/hệ thống mà chưa có kết quả → trả null (huỷ).
      canPop: true,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context).paymentVnpayTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: _progress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress,
                    minHeight: 2,
                    backgroundColor: Colors.white24,
                  ),
                )
              : null,
        ),
        body: _loadError != null
            ? _LoadErrorView(
                message: _loadError!,
                onClose: () => Navigator.of(context).pop(),
              )
            : InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.payUrl)),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  javaScriptEnabled: true,
                ),
                shouldOverrideUrlLoading: (controller, action) async {
                  final uri = action.request.url;
                  final params = uri == null ? null : _extractReturnParams(uri);
                  if (params != null) {
                    _finishWith(params);
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onProgressChanged: (controller, progress) {
                  if (mounted) setState(() => _progress = progress / 100);
                },
                onReceivedServerTrustAuthRequest: (controller, challenge) async {
                  final host = challenge.protectionSpace.host;
                  return ServerTrustAuthResponse(
                    action: host == _trustedSandboxHost
                        ? ServerTrustAuthResponseAction.PROCEED
                        : ServerTrustAuthResponseAction.CANCEL,
                  );
                },
                onReceivedError: (controller, request, error) {
                  // Chỉ lỗi main frame mới thay cả trang; lỗi resource phụ bỏ qua.
                  if (request.isForMainFrame != true || !mounted) return;
                  setState(
                    () => _loadError =
                        '${error.description} (${error.type})',
                  );
                },
              ),
      ),
    );
  }
}

/// Màn lỗi khi WebView không tải được cổng thanh toán (mạng/SSL) — thay vì
/// để trang trắng không thông báo gì.
class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: context.palette.mutedText,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.paymentGatewayLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.palette.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.palette.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onClose,
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }
}
