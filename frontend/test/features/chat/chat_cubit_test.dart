import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/chat/domain/entities/conversation.dart';
import 'package:frontend/features/chat/domain/entities/message.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/chat/domain/usecases/list_messages_usecase.dart';
import 'package:frontend/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:frontend/features/chat/presentation/cubit/chat_cubit.dart';

/// Fake repo cấu hình được — không chạm mạng.
class _FakeChatRepository implements ChatRepository {
  /// page → danh sách server trả (mới → cũ, như backend).
  Map<int, List<Message>> pages = {};
  Object? listError;
  Message? sendResult;
  Object? sendError;

  @override
  Future<List<Message>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
  }) async {
    if (listError != null) throw listError!;
    return pages[page] ?? const [];
  }

  @override
  Future<Message> sendMessage(String conversationId, String body) async {
    if (sendError != null) throw sendError!;
    return sendResult!;
  }

  @override
  Future<List<Conversation>> listConversations() async => const [];

  @override
  Future<Conversation> createOrGetConversation({
    String? participantId,
    String? bookingId,
  }) => throw UnimplementedError();
}

Message _msg(String id, {int minute = 0, String sender = 'u1'}) => Message(
  id: id,
  conversationId: 'c1',
  senderId: sender,
  body: 'msg $id',
  sentAt: DateTime(2026, 1, 1, 10, minute),
  readAt: null,
);

void main() {
  late _FakeChatRepository repo;

  ChatCubit build() => ChatCubit(
    listMessages: ListMessagesUseCase(repo),
    sendMessage: SendMessageUseCase(repo),
  );

  setUp(() => repo = _FakeChatRepository());

  test('start nạp tin nhắn theo thứ tự cũ → mới', () async {
    repo.pages = {
      1: [_msg('m2', minute: 2), _msg('m1', minute: 1)],
    };
    final cubit = build();
    await cubit.start('c1');
    final state = cubit.state as ChatLoaded;
    expect(state.messages.map((m) => m.id).toList(), ['m1', 'm2']);
    expect(state.hasMore, isFalse); // < 50 tin → hết.
    await cubit.close();
  });

  test('start lỗi API → ChatError', () async {
    repo.listError = const ApiException('Mất mạng');
    final cubit = build();
    await cubit.start('c1');
    expect(cubit.state, isA<ChatError>());
    expect((cubit.state as ChatError).message, 'Mất mạng');
    await cubit.close();
  });

  test('start đủ 50 tin → hasMore = true', () async {
    repo.pages = {
      1: List.generate(50, (i) => _msg('m$i', minute: 59 - i)),
    };
    final cubit = build();
    await cubit.start('c1');
    expect((cubit.state as ChatLoaded).hasMore, isTrue);
    await cubit.close();
  });

  test('send thành công: thêm tin, isSending về false', () async {
    repo.pages = {
      1: [_msg('m1', minute: 1)],
    };
    repo.sendResult = _msg('m2', minute: 2, sender: 'me');
    final cubit = build();
    await cubit.start('c1');
    final error = await cubit.send('hello');
    expect(error, isNull);
    final state = cubit.state as ChatLoaded;
    expect(state.messages.map((m) => m.id).toList(), ['m1', 'm2']);
    expect(state.isSending, isFalse);
    await cubit.close();
  });

  test('send không nhân đôi khi poll đã trả tin đó (dedupe theo id)', () async {
    repo.pages = {
      1: [_msg('m2', minute: 2), _msg('m1', minute: 1)],
    };
    // Server đã có m2 (poll kịp trả) và send() cũng trả về m2.
    repo.sendResult = _msg('m2', minute: 2);
    final cubit = build();
    await cubit.start('c1');
    await cubit.send('hello');
    final ids = (cubit.state as ChatLoaded).messages.map((m) => m.id).toList();
    expect(ids, ['m1', 'm2']);
    await cubit.close();
  });

  test('send lỗi: trả message lỗi, giữ nguyên tin, isSending false', () async {
    repo.pages = {
      1: [_msg('m1', minute: 1)],
    };
    repo.sendError = const ApiException('Gửi thất bại');
    final cubit = build();
    await cubit.start('c1');
    final error = await cubit.send('hello');
    expect(error, 'Gửi thất bại');
    final state = cubit.state as ChatLoaded;
    expect(state.messages.length, 1);
    expect(state.isSending, isFalse);
    await cubit.close();
  });

  test('loadMore chèn tin cũ lên đầu, dedupe, cập nhật hasMore', () async {
    repo.pages = {
      1: List.generate(50, (i) => _msg('new$i', minute: 59 - i)),
      2: [_msg('old1', minute: 0), _msg('new49', minute: 10)],
    };
    final cubit = build();
    await cubit.start('c1');
    await cubit.loadMore();
    final state = cubit.state as ChatLoaded;
    expect(state.messages.first.id, 'old1');
    // new49 có ở cả 2 trang → chỉ 1 bản.
    expect(state.messages.where((m) => m.id == 'new49').length, 1);
    expect(state.messages.length, 51);
    expect(state.hasMore, isFalse); // trang 2 < 50 tin.
    expect(state.isLoadingMore, isFalse);
    await cubit.close();
  });

  test('loadMore không chạy khi hasMore = false', () async {
    repo.pages = {
      1: [_msg('m1', minute: 1)],
    };
    final cubit = build();
    await cubit.start('c1');
    repo.pages[2] = [_msg('old1', minute: 0)];
    await cubit.loadMore();
    expect((cubit.state as ChatLoaded).messages.length, 1);
    await cubit.close();
  });
}
