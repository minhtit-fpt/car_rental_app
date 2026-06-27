import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/di/injector.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import 'package:frontend/features/ai_chat/presentation/screens/ai_chat_screen.dart';

final aiChatRoutes = [
  GoRoute(
    path: '/ai-chat',
    builder: (context, state) => BlocProvider(
      create: (_) => sl<AiChatCubit>(),
      child: const AiChatScreen(),
    ),
  ),
];
