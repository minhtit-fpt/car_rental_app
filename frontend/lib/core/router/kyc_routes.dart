import 'package:go_router/go_router.dart';
import 'package:frontend/features/kyc/presentation/screens/kyc_upload_screen.dart';
import 'package:frontend/features/kyc/presentation/screens/kyc_status_screen.dart';

final kycRoutes = [
  GoRoute(
    path: '/kyc/upload',
    builder: (context, state) => const KycUploadScreen(),
  ),
  GoRoute(
    path: '/kyc/status',
    builder: (context, state) {
      final status = state.extra as KycStatus? ?? KycStatus.pending;
      return KycStatusScreen(status: status);
    },
  ),
];
