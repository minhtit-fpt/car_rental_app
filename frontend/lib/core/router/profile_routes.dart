import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/change_password_cubit.dart';
import 'package:frontend/features/profile/presentation/screens/change_password_screen.dart';
import 'package:frontend/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:frontend/features/profile/presentation/screens/settings_screen.dart';
import 'package:frontend/features/profile/presentation/screens/terms_screen.dart';

final profileRoutes = [
  GoRoute(
    path: '/profile/edit',
    builder: (context, state) => const EditProfileScreen(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
  GoRoute(
    path: '/change-password',
    builder: (context, state) => BlocProvider(
      create: (_) =>
          ChangePasswordCubit(ChangePasswordUseCase(sl<AuthRepository>())),
      child: const ChangePasswordScreen(),
    ),
  ),
];
