import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/ai_chat/domain/entities/chat_message.dart';
import 'package:frontend/features/ai_chat/domain/repositories/ai_chat_repository.dart';
import 'package:frontend/features/ai_chat/domain/usecases/stream_ai_reply_usecase.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import 'package:frontend/features/ai_chat/presentation/cubit/ai_chat_state.dart';

/// Fake repo cấu hình được — không chạm mạng/AI service.
class _FakeAiChatRepository implements AiChatRepository {
  List<String> deltas = const [];
  Object? error;
  List<ChatMessage>? capturedHistory;

  @override
  Stream<String> streamReply({
    required String message,
    required List<ChatMessage> history,
  }) {
    capturedHistory = history;
    if (error != null) return Stream<String>.error(error!);
    return Stream<String>.fromIterable(deltas);
  }
}

void main() {
  late _FakeAiChatRepository repo;

  AiChatCubit build() =>
      AiChatCubit(streamReply: StreamAiReplyUseCase(repo));

  setUp(() => repo = _FakeAiChatRepository());

  test('bỏ qua tin nhắn rỗng', () async {
    final cubit = build();
    await cubit.send('   ');
    expect(cubit.state.messages, isEmpty);
    await cubit.close();
  });

  blocTest<AiChatCubit, AiChatState>(
    'nối dần delta vào tin assistant, kết thúc isStreaming=false',
    build: () {
      repo.deltas = ['Xin ', 'chào ', 'bạn'];
      return build();
    },
    act: (c) => c.send('hello'),
    verify: (c) {
      final msgs = c.state.messages;
      expect(msgs.length, 2);
      expect(msgs.first.role, ChatRole.user);
      expect(msgs.last.role, ChatRole.assistant);
      expect(msgs.last.content, 'Xin chào bạn');
      expect(msgs.last.isStreaming, isFalse);
      expect(c.state.isStreaming, isFalse);
    },
  );

  blocTest<AiChatCubit, AiChatState>(
    'lỗi stream → gỡ tin assistant rỗng và đặt error',
    build: () {
      repo.error = const ApiException('AI lỗi', code: 'AI_UNREACHABLE');
      return build();
    },
    act: (c) => c.send('hi'),
    verify: (c) {
      expect(c.state.error, 'AI lỗi');
      expect(c.state.isStreaming, isFalse);
      // Chỉ còn tin của người dùng, không còn assistant rỗng.
      expect(c.state.messages.length, 1);
      expect(c.state.messages.single.role, ChatRole.user);
    },
  );

  test('history gửi đi KHÔNG gồm lượt hiện tại', () async {
    repo.deltas = ['ok'];
    final cubit = build();
    await cubit.send('câu 1');
    // Chờ stream lượt 1 chạy xong (Stream.fromIterable phát qua microtask).
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await cubit.send('câu 2');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    // Lần gửi 2: history = [user:câu1, assistant:ok] (2 lượt trước).
    expect(repo.capturedHistory!.length, 2);
    expect(repo.capturedHistory!.last.content, 'ok');
    await cubit.close();
  });

  test('tách metadata xe khỏi văn bản hiển thị (sentinel)', () async {
    // Delta cuối mang sentinel + JSON vehicles (như ai-service phát ra).
    repo.deltas = [
      'Có xe Toyota Vios 2022 cho bạn.',
      '{"vehicles":[{"id":"v1","name":"Toyota Vios 2022"}]}',
    ];
    final cubit = build();
    await cubit.send('xe 4 chỗ?');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final last = cubit.state.messages.last;
    // Văn bản hiển thị KHÔNG chứa sentinel/JSON.
    expect(last.content, 'Có xe Toyota Vios 2022 cho bạn.');
    expect(last.vehicles.length, 1);
    expect(last.vehicles.single.id, 'v1');
    expect(last.vehicles.single.name, 'Toyota Vios 2022');
    await cubit.close();
  });

  test('startNewChat xoá sạch hội thoại', () async {
    repo.deltas = ['ok'];
    final cubit = build();
    await cubit.send('câu 1');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.messages, isNotEmpty);
    cubit.startNewChat();
    expect(cubit.state.messages, isEmpty);
    await cubit.close();
  });

  test('history gửi đi cắt còn tối đa 10 tin gần nhất', () async {
    repo.deltas = ['ok'];
    final cubit = build();
    // 6 lượt hỏi-đáp = 12 tin hoàn tất trước lượt thứ 7.
    for (var i = 0; i < 7; i++) {
      await cubit.send('câu $i');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(repo.capturedHistory!.length, 10);
    await cubit.close();
  });
}
