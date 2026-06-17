import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_status_cubit.dart';
import 'package:frontend/features/kyc/presentation/screens/kyc_upload_screen.dart';
import 'package:frontend/features/kyc/presentation/screens/kyc_status_screen.dart';

final kycRoutes = [
  GoRoute(
    path: '/kyc/upload',
    builder: (context, state) => const KycUploadScreen(),
  ),
  GoRoute(
    path: '/kyc/status',
    builder: (context, state) => BlocProvider(
      create: (_) => sl<KycStatusCubit>()..load(),
      child: const KycStatusScreen(),
    ),
  ),
];
