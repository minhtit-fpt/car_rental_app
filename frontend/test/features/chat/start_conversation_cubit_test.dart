import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/chat/domain/usecases/create_or_get_conversation_usecase.dart';
import 'package:frontend/features/chat/presentation/cubit/start_conversation_cubit.dart';

class _FakeChatRepository implements ChatRepository {
  Conversation? result;
  Object? error;
  String? capturedParticipantId;
  String? capturedBookingId;

  @override
  Future<Conversation> createOrGetConversation({
    String? participantId,
    String? bookingId,
  }) async {
    capturedParticipantId = participantId;
    capturedBookingId = bookingId;
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<List<Conversation>> listConversations() async => const [];

  @override
  Future<List<Message>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
  }) => throw UnimplementedError();

  @override
  Future<Message> sendMessage(String conversationId, String body) =>
      throw UnimplementedError();
}

void main() {
  late _FakeChatRepository repo;

  StartConversationCubit build() => StartConversationCubit(
    createOrGetConversation: CreateOrGetConversationUseCase(repo),
  );

  setUp(() => repo = _FakeChatRepository());

  test('open theo bookingId → Ready kèm partnerName', () async {
    repo.result = const Conversation(
      id: 'c1',
      unreadCount: 0,
      bookingId: 'b1',
      partner: ChatPartner(id: 'u2', name: 'Chủ Xe A'),
    );
    final cubit = build();
    await cubit.open(bookingId: 'b1');
    final state = cubit.state as StartConversationReady;
    expect(state.conversationId, 'c1');
    expect(state.partnerName, 'Chủ Xe A');
    expect(repo.capturedBookingId, 'b1');
    expect(repo.capturedParticipantId, isNull);
    await cubit.close();
  });

  test('open theo participantId → Ready', () async {
    repo.result = const Conversation(id: 'c2', unreadCount: 0);
    final cubit = build();
    await cubit.open(participantId: 'u2');
    expect((cubit.state as StartConversationReady).conversationId, 'c2');
    expect(repo.capturedParticipantId, 'u2');
    await cubit.close();
  });

  test('open lỗi API → Error', () async {
    repo.error = const ApiException('Không tìm thấy đơn đặt');
    final cubit = build();
    await cubit.open(bookingId: 'b1');
    expect(
      (cubit.state as StartConversationError).message,
      'Không tìm thấy đơn đặt',
    );
    await cubit.close();
  });
}
