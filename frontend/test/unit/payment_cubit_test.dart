import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/payment/domain/entities/payment.dart';
import 'package:frontend/features/payment/domain/payment_exception.dart';
import 'package:frontend/features/payment/domain/usecases/confirm_payment_usecase.dart';
import 'package:frontend/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_state.dart';

class MockCreatePaymentUseCase extends Mock implements CreatePaymentUseCase {}

class MockConfirmPaymentUseCase extends Mock implements ConfirmPaymentUseCase {}

void main() {
  late MockCreatePaymentUseCase createPayment;
  late MockConfirmPaymentUseCase confirmPayment;

  const session = PaymentSession(
    paymentId: 'pay-1',
    payUrl: 'https://sandbox/pay?ref=book-1',
    status: PaymentStatus.pending,
  );

  setUp(() {
    createPayment = MockCreatePaymentUseCase();
    confirmPayment = MockConfirmPaymentUseCase();
  });

  PaymentCubit build() => PaymentCubit(
        createPayment: createPayment,
        confirmPayment: confirmPayment,
      );

  blocTest<PaymentCubit, PaymentFlowState>(
    'start emits [creating, ready] with the session',
    setUp: () =>
        when(() => createPayment('book-1')).thenAnswer((_) async => session),
    build: build,
    act: (cubit) => cubit.start('book-1'),
    expect: () => [
      const PaymentCreating(),
      const PaymentReady(session),
    ],
  );

  blocTest<PaymentCubit, PaymentFlowState>(
    'start jumps to paid when the gateway returns an already-paid session',
    setUp: () => when(() => createPayment('book-1')).thenAnswer(
      (_) async => const PaymentSession(
        paymentId: 'pay-1',
        payUrl: 'https://sandbox/pay',
        status: PaymentStatus.paid,
      ),
    ),
    build: build,
    act: (cubit) => cubit.start('book-1'),
    expect: () => [const PaymentCreating(), const PaymentPaid()],
  );

  blocTest<PaymentCubit, PaymentFlowState>(
    'start emits failure when creation throws',
    setUp: () => when(() => createPayment('book-1'))
        .thenThrow(const PaymentException('Đơn không hợp lệ', code: 'X')),
    build: build,
    act: (cubit) => cubit.start('book-1'),
    expect: () => [
      const PaymentCreating(),
      const PaymentFlowFailure('Đơn không hợp lệ', code: 'X'),
    ],
  );

  blocTest<PaymentCubit, PaymentFlowState>(
    'confirm(success) emits [ready+confirming, paid]',
    setUp: () {
      when(() => createPayment('book-1')).thenAnswer((_) async => session);
      when(() => confirmPayment('pay-1', success: true))
          .thenAnswer((_) async => PaymentStatus.paid);
    },
    build: build,
    act: (cubit) async {
      await cubit.start('book-1');
      await cubit.confirm(success: true);
    },
    skip: 2, // skip creating + ready from start
    expect: () => [
      const PaymentReady(session, confirming: true),
      const PaymentPaid(),
    ],
  );

  blocTest<PaymentCubit, PaymentFlowState>(
    'confirm(failure) emits a failure that keeps the session for retry',
    setUp: () {
      when(() => createPayment('book-1')).thenAnswer((_) async => session);
      when(() => confirmPayment('pay-1', success: false))
          .thenAnswer((_) async => PaymentStatus.failed);
    },
    build: build,
    act: (cubit) async {
      await cubit.start('book-1');
      await cubit.confirm(success: false);
    },
    skip: 2,
    expect: () => [
      const PaymentReady(session, confirming: true),
      isA<PaymentFlowFailure>()
          .having((s) => s.session, 'session', session),
    ],
  );

  blocTest<PaymentCubit, PaymentFlowState>(
    'reset returns from a confirm failure back to ready',
    setUp: () {
      when(() => createPayment('book-1')).thenAnswer((_) async => session);
      when(() => confirmPayment('pay-1', success: false))
          .thenAnswer((_) async => PaymentStatus.failed);
    },
    build: build,
    act: (cubit) async {
      await cubit.start('book-1');
      await cubit.confirm(success: false);
      cubit.reset();
    },
    // creating, ready, ready+confirming, failure → then reset emits ready
    skip: 4,
    expect: () => [const PaymentReady(session)],
  );
}
