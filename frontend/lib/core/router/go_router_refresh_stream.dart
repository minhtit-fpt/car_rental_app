import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapter biến một Stream (cubit.stream) thành Listenable cho GoRouter,
/// để router chạy lại redirect mỗi khi auth state đổi.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
