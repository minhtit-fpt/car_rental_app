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
        body: InAppWebView(
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
        ),
      ),
    );
  }
}
