import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/di/injector.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import 'package:frontend/features/ai_chat/presentation/screens/ai_chat_screen.dart';

final aiChatRoutes = [
  GoRoute(
    path: '/ai-chat',
    // .value: cubit là singleton (giữ hội thoại qua điều hướng), không tạo mới
    // mỗi lần vào route và không bị đóng khi rời màn.
    builder: (context, state) => BlocProvider.value(
      value: sl<AiChatCubit>(),
      child: const AiChatScreen(),
    ),
  ),
];
