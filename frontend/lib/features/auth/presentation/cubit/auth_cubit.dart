import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/auth_state.dart';

export 'package:frontend/features/auth/domain/entities/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthIdle());

  Future<void> sendOtp(String phone) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    emit(AuthOtpSent(phone));
  }

  Future<void> verifyOtp(String otp) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    if (otp == '123456') {
      emit(AuthSuccess());
    } else {
      emit(AuthError('Mã OTP không đúng. Vui lòng thử lại.'));
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
  }) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    emit(AuthOtpSent(phone));
  }

  void reset() => emit(AuthIdle());
}
