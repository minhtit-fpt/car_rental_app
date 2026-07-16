import 'package:go_router/go_router.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart';
import 'package:frontend/features/chat/presentation/screens/conversation_list_screen.dart';
import 'package:frontend/features/community/presentation/screens/community_feed_screen.dart';
import 'package:frontend/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:frontend/features/notification/presentation/screens/notification_list_screen.dart';
import 'package:frontend/features/review/presentation/screens/user_reviews_screen.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';

final socialRoutes = [
  GoRoute(
    path: '/conversations',
    builder: (context, state) => const ConversationListScreen(),
  ),
  GoRoute(
    path: '/chat/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final name =
          state.extra as String? ??
          AppLocalizations.of(context).chatPartnerFallback;
      return ChatScreen(conversationId: id, partnerName: name);
    },
  ),
  GoRoute(
    path: '/reviews/:userId',
    builder: (context, state) {
      final userId = state.pathParameters['userId']!;
      final userName = state.extra as String?;
      return UserReviewsScreen(userId: userId, userName: userName);
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
