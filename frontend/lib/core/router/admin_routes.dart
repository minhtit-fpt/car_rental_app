import 'package:go_router/go_router.dart';
import 'package:frontend/features/admin/presentation/screens/dispute_detail_screen.dart';
import 'package:frontend/features/admin/presentation/screens/kyc_detail_screen.dart';
import 'package:frontend/features/admin/presentation/screens/user_detail_screen.dart';

final adminRoutes = [
  GoRoute(
    path: '/admin/kyc/:id',
    builder: (context, state) => const KycDetailScreen(),
  ),
  GoRoute(
    path: '/admin/user/:id',
    builder: (context, state) => const UserDetailScreen(),
  ),
  GoRoute(
    path: '/admin/dispute/:id',
    builder: (context, state) => const DisputeDetailScreen(),
  ),
];
