import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/analyze_dispute_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/ask_analytics_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/explain_risk_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_booking_detail_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/get_kyc_documents_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_bookings_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_risk_flags_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/refund_payment_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/resolve_dispute_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/review_kyc_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/update_user_role_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_analytics_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_booking_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_bookings_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_risk_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_user_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/screens/admin_analytics_screen.dart';
import 'package:frontend/features/admin/presentation/screens/booking_detail_screen.dart';
import 'package:frontend/features/admin/presentation/screens/booking_list_screen.dart';
import 'package:frontend/features/admin/presentation/screens/risk_queue_screen.dart';
import 'package:frontend/features/admin/presentation/screens/dispute_detail_screen.dart';
import 'package:frontend/features/admin/presentation/screens/kyc_detail_screen.dart';
import 'package:frontend/features/admin/presentation/screens/user_detail_screen.dart';

final adminRoutes = [
  GoRoute(
    path: '/admin/kyc/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final item = state.extra as AdminKycItem?;
      return BlocProvider(
        create: (_) => AdminKycDetailCubit(
          kycId: id,
          getDocuments: GetKycDocumentsUseCase(sl<AdminRepository>()),
          reviewKyc: ReviewKycUseCase(sl<AdminRepository>()),
        )..loadDocuments(),
        child: KycDetailScreen(item: item),
      );
    },
  ),
  GoRoute(
    path: '/admin/user/:id',
    builder: (context, state) {
      final item = state.extra as AdminUserItem?;
      if (item == null) return const UserDetailMissing();
      return BlocProvider(
        create: (_) => AdminUserDetailCubit(
          user: item,
          updateUserRole: UpdateUserRoleUseCase(sl<AdminRepository>()),
        ),
        child: const UserDetailScreen(),
      );
    },
  ),
  GoRoute(
    path: '/admin/bookings',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => AdminBookingsCubit(
          listBookings: ListAdminBookingsUseCase(sl<AdminRepository>()),
        )..load(),
        child: const BookingListScreen(),
      );
    },
  ),
  GoRoute(
    path: '/admin/booking/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return BlocProvider(
        create: (_) => AdminBookingDetailCubit(
          bookingId: id,
          getDetail: GetAdminBookingDetailUseCase(sl<AdminRepository>()),
          refundPayment: RefundPaymentUseCase(sl<AdminRepository>()),
        )..load(),
        child: const BookingDetailScreen(),
      );
    },
  ),
  GoRoute(
    path: '/admin/risk',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => AdminRiskCubit(
          listRiskFlags: ListRiskFlagsUseCase(sl<AdminRepository>()),
          explainRisk: ExplainRiskUseCase(sl<AdminRepository>()),
        )..load(),
        child: const RiskQueueScreen(),
      );
    },
  ),
  GoRoute(
    path: '/admin/analytics',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => AdminAnalyticsCubit(
          askAnalytics: AskAnalyticsUseCase(sl<AdminRepository>()),
        ),
        child: const AdminAnalyticsScreen(),
      );
    },
  ),
  GoRoute(
    path: '/admin/dispute/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final item = state.extra as AdminDisputeItem?;
      return BlocProvider(
        create: (_) => AdminDisputeDetailCubit(
          disputeId: id,
          resolveDispute: ResolveDisputeUseCase(sl<AdminRepository>()),
          analyzeDispute: AnalyzeDisputeUseCase(sl<AdminRepository>()),
        ),
        child: DisputeDetailScreen(item: item),
      );
    },
  ),
];
