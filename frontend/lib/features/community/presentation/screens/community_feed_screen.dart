import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/section_header.dart';

class _Story {
  const _Story({
    required this.id,
    required this.author,
    required this.vehicleName,
    required this.location,
    required this.content,
    required this.emoji,
    required this.likes,
    required this.comments,
    required this.time,
    this.isLiked = false,
  });
  final String id;
  final String author;
  final String vehicleName;
  final String location;
  final String content;
  final String emoji;
  final int likes;
  final int comments;
  final String time;
  final bool isLiked;
}

const _kStories = [
  _Story(
    id: '1',
    author: 'Thanh N.',
    vehicleName: 'Tesla Model 3',
    location: 'Hà Nội → Ninh Bình',
    content:
        'Chuyến đi tuyệt vời với Tesla Model 3! Xe chạy êm, pin đủ cho cả chặng đường. Cảnh đẹp dọc đường đi Ninh Bình khiến mọi người đều thích thú. Sẽ thuê lại lần sau! ⚡🌿',
    emoji: '🚗',
    likes: 47,
    comments: 12,
    time: '2 giờ trước',
    isLiked: true,
  ),
  _Story(
    id: '2',
    author: 'Hùng P.',
    vehicleName: 'BMW X5',
    location: 'TP.HCM → Vũng Tàu',
    content:
        'Cuối tuần chạy BMW X5 ra Vũng Tàu với gia đình. Xe rộng, thoải mái cho 5 người. Chủ xe nhiệt tình, giao xe tận nhà. Highly recommend! 🏖️',
    emoji: '🚙',
    likes: 31,
    comments: 8,
    time: '5 giờ trước',
  ),
  _Story(
    id: '3',
    author: 'Linh H.',
    vehicleName: 'Kia EV6',
    location: 'Đà Nẵng → Hội An',
    content:
        'Lần đầu thuê xe điện để đi Hội An. Trải nghiệm hoàn toàn khác! Yên tĩnh, không khí trong lành hơn. EV là tương lai của du lịch xanh 🌱⚡',
    emoji: '⚡',
    likes: 63,
    comments: 24,
    time: 'Hôm qua',
  ),
];

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _likedStories = <String>{};

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
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
                    'Cộng đồng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.border),
              ),
            ),
          ],
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _WriteStoryBanner(),
                      const SizedBox(height: 16),
                      const SectionHeader(
                          title: 'Câu chuyện mới nhất'),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList.separated(
                  itemCount: _kStories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final story = _kStories[index];
                    final isLiked = _likedStories.contains(story.id) ||
                        story.isLiked;
                    return _StoryCard(
                      story: story,
                      isLiked: isLiked,
                      onLike: () {
                        setState(() {
                          if (_likedStories.contains(story.id)) {
                            _likedStories.remove(story.id);
                          } else {
                            _likedStories.add(story.id);
                          }
                        });
                      },
                      onTap: () =>
                          context.push('/community/${story.id}', extra: story),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WriteStoryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✍️', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Chia sẻ chuyến đi của bạn...',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.mutedText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.story,
    required this.isLiked,
    required this.onLike,
    required this.onTap,
  });

  final _Story story;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Image area (placeholder with gradient + emoji)
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(story.emoji,
                        style: const TextStyle(fontSize: 64)),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            story.location,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('👤',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.author,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              '🚗 ${story.vehicleName} · ${story.time}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    story.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isLiked
                                  ? AppColors.danger
                                  : AppColors.mutedText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${story.likes + (isLiked && !story.isLiked ? 1 : 0)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 16, color: AppColors.mutedText),
                          const SizedBox(width: 4),
                          Text(
                            '${story.comments}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.share_outlined,
                          size: 16, color: AppColors.mutedText),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
