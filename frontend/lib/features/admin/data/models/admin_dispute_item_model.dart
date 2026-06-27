import 'package:frontend/features/admin/domain/entities/admin_dispute_item.dart';

abstract final class AdminDisputeItemModel {
  static AdminDisputeItem fromJson(Map<String, dynamic> json) =>
      AdminDisputeItem(
        id: json['id'] as String,
        bookingId: json['bookingId'] as String,
        title: json['title'] as String,
        priority: json['priority'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
