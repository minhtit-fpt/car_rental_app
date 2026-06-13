import 'package:go_router/go_router.dart';
import 'package:frontend/features/profile/presentation/screens/edit_profile_screen.dart';

final profileRoutes = [
  GoRoute(
    path: '/profile/edit',
    builder: (context, state) => const EditProfileScreen(),
  ),
];
