import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/injector.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/review/presentation/cubit/review_cubit.dart';
import 'package:frontend/features/vehicle/domain/entities/vehicle.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/rating_stars.dart';
import 'package:frontend/shared/widgets/rv_sliver_app_bar.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.vehicle,
  });

  /// Đơn đã hoàn tất/đang diễn ra cần đánh giá.
  final String bookingId;
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReviewCubit>(),
      child: _ReviewView(bookingId: bookingId, vehicle: vehicle),
    );
  }
}

class _ReviewView extends StatefulWidget {
  const _ReviewView({required this.bookingId, required this.vehicle});

  final String bookingId;
  final Vehicle vehicle;

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  int _vehicleRating = 0;
  int _ownerRating = 0;
  final _commentController = TextEditingController();
  final List<String> _selectedTags = [];

  static const _positiveTags = [
    'Xe sạch',
    'Đúng giờ',
    'Chủ xe thân thiện',
    'Xe đúng mô tả',
    'Giao xe tận nơi',
    'Giá hợp lý',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _vehicleRating > 0 && _ownerRating > 0;

  void _submit(BuildContext context) {
    final tagNote = _selectedTags.join(', ');
    final text = _commentController.text.trim();
    final comment = [tagNote, text].where((s) => s.isNotEmpty).join(' — ');
    // Backend lưu 1 đánh giá/đơn (người thuê → chủ xe). Gộp 2 thang điểm thành
    // điểm tổng để khớp model một-rating của backend.
    final rating = ((_vehicleRating + _ownerRating) / 2).round().clamp(1, 5);
    context.read<ReviewCubit>().submit(
      bookingId: widget.bookingId,
      rating: rating,
      comment: comment.isEmpty ? null : comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const RvSliverAppBar(
              title: 'Đánh giá chuyến đi',
              subtitle: 'Chia sẻ trải nghiệm của bạn',
              role: RvRole.renter,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _VehicleCard(vehicle: widget.vehicle),
                    const SizedBox(height: 20),
                    _RatingCard(
                      title: 'Chất lượng xe',
                      emoji: '🚗',
                      rating: _vehicleRating,
                      onRatingChanged: (r) =>
                          setState(() => _vehicleRating = r),
                    ),
                    const SizedBox(height: 16),
                    _RatingCard(
                      title: 'Chủ xe',
                      emoji: '👤',
                      subtitle: widget.vehicle.ownerName ?? 'Chủ xe',
                      rating: _ownerRating,
                      onRatingChanged: (r) => setState(() => _ownerRating = r),
                    ),

                    const SizedBox(height: 16),
                    _TagsCard(
                      tags: _positiveTags,
                      selected: _selectedTags,
                      onToggle: (tag) {
                        setState(() {
                          if (_selectedTags.contains(tag)) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _CommentCard(controller: _commentController),
                    const SizedBox(height: 20),
                    BlocConsumer<ReviewCubit, ReviewSubmitState>(
                      listener: (context, state) {
                        switch (state) {
                          case ReviewSubmitted():
                            context.go('/');
                          case ReviewSubmitError(:final message):
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: AppColors.accent,
                                ),
                              );
                          case ReviewIdle():
                          case ReviewSubmitting():
                            break;
                        }
                      },
                      builder: (context, state) {
                        final isSubmitting = state is ReviewSubmitting;
                        return PrimaryButton(
                          label: 'Gửi đánh giá',
                          onPressed: _canSubmit && !isSubmitting
                              ? () => _submit(context)
                              : null,
                          isLoading: isSubmitting,
                          icon: Icons.star_rounded,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.cardImageGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(vehicle.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  vehicle.isElectric
                      ? 'Điện · ${vehicle.typeLabel}'
                      : vehicle.typeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withAlpha(80)),
            ),
            child: const Text(
              '✅ Đã hoàn thành',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.title,
    required this.emoji,
    this.subtitle,
    required this.rating,
    required this.onRatingChanged,
  });

  final String title;
  final String emoji;
  final String? subtitle;
  final int rating;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final labels = ['', 'Tệ', 'Không ổn', 'Bình thường', 'Tốt', 'Xuất sắc'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          InteractiveRatingStars(
            onRatingChanged: onRatingChanged,
            initialRating: rating,
            size: 36,
          ),
          if (rating > 0) ...[
            const SizedBox(height: 8),
            Text(
              labels[rating.clamp(0, 5)],
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.starYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TagsCard extends StatelessWidget {
  const _TagsCard({
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  final List<String> tags;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điểm nổi bật',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final isSelected = selected.contains(tag);
              return GestureDetector(
                onTap: () => onToggle(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(26)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondaryText,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhận xét thêm (tùy chọn)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }
}
