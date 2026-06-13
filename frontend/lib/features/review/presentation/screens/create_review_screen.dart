import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';
import 'package:frontend/features/review/presentation/cubit/create_review_cubit.dart';
import 'package:frontend/features/review/presentation/cubit/create_review_state.dart';

/// Màn tạo đánh giá cho một đơn (Phase 5). Renter ↔ chủ xe.
class CreateReviewScreen extends StatelessWidget {
  const CreateReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateReviewCubit>(
      create: (_) => getIt<CreateReviewCubit>(),
      child: _CreateReviewView(bookingId: bookingId),
    );
  }
}

class _CreateReviewView extends StatefulWidget {
  const _CreateReviewView({required this.bookingId});

  final String bookingId;

  @override
  State<_CreateReviewView> createState() => _CreateReviewViewState();
}

class _CreateReviewViewState extends State<_CreateReviewView> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<CreateReviewCubit>().submit(
          CreateReviewParams(
            bookingId: widget.bookingId,
            rating: _rating,
            comment: _commentController.text.trim(),
          ),
        );
  }

  void _onStateChange(BuildContext context, CreateReviewState state) {
    if (state is CreateReviewSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
        );
      Navigator.of(context).pop(true);
    } else if (state is CreateReviewFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF003380),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Đánh giá',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocListener<CreateReviewCubit, CreateReviewState>(
          listener: _onStateChange,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Card(
                child: Column(
                  children: [
                    const Text(
                      'Bạn chấm chuyến đi này mấy sao?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StarPicker(
                      rating: _rating,
                      onChanged: (r) => setState(() => _rating = r),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhận xét (tuỳ chọn)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ trải nghiệm của bạn...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<CreateReviewCubit, CreateReviewState>(
              builder: (context, state) {
                final submitting = state is CreateReviewSubmitting;
                return FilledButton(
                  onPressed: submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Gửi đánh giá',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StarPicker extends StatelessWidget {
  const _StarPicker({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final value = i + 1;
        final filled = value <= rating;
        return IconButton(
          onPressed: () => onChanged(value),
          iconSize: 40,
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? AppColors.orange : AppColors.mutedText,
          ),
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}
