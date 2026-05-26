import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';

enum _NotifType { booking, payment, system, promo }

class _Notif {
  const _Notif({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
  final String title;
  final String body;
  final String time;
  final _NotifType type;
  final bool isRead;
}

const _kNotifs = [
  _Notif(
    title: 'Chuyến đi được xác nhận',
    body: 'Tesla Model 3 đã được xác nhận cho ngày 20/05. Chúc bạn có chuyến đi vui vẻ!',
    time: 'Vừa xong',
    type: _NotifType.booking,
  ),
  _Notif(
    title: 'Thanh toán thành công',
    body: 'Giao dịch 890K VNĐ đã được xử lý thành công qua VNPay.',
    time: '5 phút trước',
    type: _NotifType.payment,
  ),
  _Notif(
    title: 'Nhắc nhở trả xe',
    body: 'Chuyến đi của bạn kết thúc vào ngày mai. Vui lòng trả xe đúng giờ.',
    time: '1 giờ trước',
    type: _NotifType.booking,
    isRead: true,
  ),
  _Notif(
    title: 'Ưu đãi dành cho bạn',
    body: 'Giảm 15% cho chuyến đi cuối tuần. Áp dụng mã WEEKEND15 khi đặt xe.',
    time: 'Hôm qua',
    type: _NotifType.promo,
    isRead: true,
  ),
  _Notif(
    title: 'KYC đã được duyệt',
    body: 'Tài khoản của bạn đã được xác minh thành công. Bạn có thể thuê xe ngay!',
    time: '2 ngày trước',
    type: _NotifType.system,
    isRead: true,
  ),
  _Notif(
    title: 'Đánh giá mới',
    body: 'Minh T. đã để lại đánh giá 5 sao cho chuyến đi của bạn.',
    time: '3 ngày trước',
    type: _NotifType.booking,
    isRead: true,
  ),
];

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount = _kNotifs.where((n) => !n.isRead).length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: AppColors.logoGradient,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _kNotifs.length,
          separatorBuilder: (_, _) =>
              const Divider(color: AppColors.border, height: 1, indent: 68),
          itemBuilder: (context, index) =>
              _NotifTile(notif: _kNotifs[index]),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif});
  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    final info = _typeInfo(notif.type);

    return InkWell(
      onTap: () {},
      child: Container(
        color: notif.isRead ? null : AppColors.primary.withAlpha(7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: info.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(info.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.time,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ({String emoji, Color color}) _typeInfo(_NotifType type) {
    return switch (type) {
      _NotifType.booking => (
          emoji: '🚗',
          color: AppColors.primary,
        ),
      _NotifType.payment => (
          emoji: '💳',
          color: AppColors.success,
        ),
      _NotifType.system => (
          emoji: '🛡️',
          color: AppColors.teal,
        ),
      _NotifType.promo => (
          emoji: '🎁',
          color: AppColors.orange,
        ),
    };
  }
}
