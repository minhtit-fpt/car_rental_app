import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit cubit;

  setUp(() {
    cubit = MockAuthCubit();
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );
  });

  Widget harness() => MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const LoginScreen(),
        ),
      );

  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();

    expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    verifyNever(() => cubit.login(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ));
  });

  testWidgets('calls login with entered credentials', (tester) async {
    when(() => cubit.login(
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {});
    await tester.pumpWidget(harness());

    await tester.enterText(find.byType(TextFormField).at(0), '0901234567');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();

    verify(() => cubit.login(phone: '0901234567', password: 'password1'))
        .called(1);
  });

  testWidgets('shows a loading indicator while authenticating',
      (tester) async {
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthLoading(),
    );
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
