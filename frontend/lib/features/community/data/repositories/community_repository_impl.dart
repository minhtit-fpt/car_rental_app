import 'package:frontend/features/community/data/datasources/community_remote_datasource.dart';
import 'package:frontend/features/community/data/models/trip_story_model.dart';
import 'package:frontend/features/community/domain/entities/trip_story.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  const CommunityRepositoryImpl(this._remote);

  final CommunityRemoteDataSource _remote;

  @override
  Future<List<TripStory>> list({int page = 1, int limit = 20}) async =>
      TripStoryModel.listFromJson(await _remote.list(page: page, limit: limit));

  @override
  Future<TripStory> create({
    required String content,
    List<String> images = const [],
  }) async => TripStoryModel.fromJson(
    await _remote.create(content: content, images: images),
  );

  @override
  Future<TripStory> like(String id) async =>
      TripStoryModel.fromJson(await _remote.like(id));
}
