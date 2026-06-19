import 'package:frontend/features/notification/domain/entities/notification.dart';

sealed class NotificationState {
  const NotificationState();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.data);
  final NotificationList data;
}

final class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
}
