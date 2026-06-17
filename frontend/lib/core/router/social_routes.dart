import 'package:go_router/go_router.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart';
import 'package:frontend/features/chat/presentation/screens/conversation_list_screen.dart';
import 'package:frontend/features/community/presentation/screens/community_feed_screen.dart';
import 'package:frontend/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:frontend/features/notification/presentation/screens/notification_list_screen.dart';

final socialRoutes = [
  GoRoute(
    path: '/conversations',
    builder: (context, state) => const ConversationListScreen(),
  ),
  GoRoute(
    path: '/chat/:id',
    builder: (context, state) {
      final name = state.extra as String? ?? 'Chủ xe';
      return ChatScreen(partnerName: name);
    },
  ),
  GoRoute(
    path: '/notifications',
    builder: (context, state) => const NotificationListScreen(),
  ),
  GoRoute(path: '/loyalty', builder: (context, state) => const LoyaltyScreen()),
  GoRoute(
    path: '/community',
    builder: (context, state) => const CommunityFeedScreen(),
  ),
];
