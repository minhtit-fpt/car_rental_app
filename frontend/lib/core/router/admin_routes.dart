import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_kyc_item.dart';
import 'package:frontend/features/admin/domain/entities/admin_user_item.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/get_kyc_documents_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/resolve_dispute_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/review_kyc_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/update_user_role_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_dispute_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_detail_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_user_detail_cubit.dart';
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
    path: '/admin/dispute/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final item = state.extra as AdminDisputeItem?;
      return BlocProvider(
        create: (_) => AdminDisputeDetailCubit(
          disputeId: id,
          resolveDispute: ResolveDisputeUseCase(sl<AdminRepository>()),
        ),
        child: DisputeDetailScreen(item: item),
      );
    },
  ),
];
