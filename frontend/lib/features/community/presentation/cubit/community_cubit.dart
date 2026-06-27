import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/community/domain/usecases/create_story_usecase.dart';
import 'package:frontend/features/community/domain/usecases/like_story_usecase.dart';
import 'package:frontend/features/community/domain/usecases/list_stories_usecase.dart';
import 'package:frontend/features/community/presentation/cubit/community_state.dart';

export 'package:frontend/features/community/presentation/cubit/community_state.dart';

/// Quản lý feed cộng đồng: nạp danh sách, đăng bài, thích.
class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit({
    required ListStoriesUseCase listStories,
    required CreateStoryUseCase createStory,
    required LikeStoryUseCase likeStory,
  }) : _listStories = listStories,
       _createStory = createStory,
       _likeStory = likeStory,
       super(const CommunityLoading());

  final ListStoriesUseCase _listStories;
  final CreateStoryUseCase _createStory;
  final LikeStoryUseCase _likeStory;

  Future<void> load() async {
    emit(const CommunityLoading());
    try {
      emit(CommunityLoaded(await _listStories()));
    } on ApiException catch (e) {
      emit(CommunityError(e.message));
    }
  }

  Future<String?> createStory(String content) async {
    try {
      final story = await _createStory(content: content);
      final current = state;
      if (current is CommunityLoaded) {
        emit(current.copyWith(stories: [story, ...current.stories]));
      } else {
        await load();
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> like(String id) async {
    final current = state;
    if (current is! CommunityLoaded || current.likedIds.contains(id)) return;
    try {
      final updated = await _likeStory(id);
      final stories = current.stories
          .map((s) => s.id == id ? s.copyWith(likes: updated.likes) : s)
          .toList(growable: false);
      emit(
        current.copyWith(stories: stories, likedIds: {...current.likedIds, id}),
      );
    } on ApiException {
      // Bỏ qua lỗi thích — giữ nguyên feed.
    }
  }
}
