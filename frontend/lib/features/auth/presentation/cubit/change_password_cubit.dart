import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/auth/domain/usecases/change_password_usecase.dart';

/// State đổi mật khẩu cho [ChangePasswordScreen] (một lần submit).
sealed class ChangePasswordState {
  const ChangePasswordState();
}

final class ChangePasswordIdle extends ChangePasswordState {
  const ChangePasswordIdle();
}

final class ChangePasswordSubmitting extends ChangePasswordState {
  const ChangePasswordSubmitting();
}

final class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

final class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure(this.message);
  final String message;
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePassword)
    : super(const ChangePasswordIdle());

  final ChangePasswordUseCase _changePassword;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordSubmitting());
    try {
      await _changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(const ChangePasswordSuccess());
    } on ApiException catch (e) {
      emit(ChangePasswordFailure(e.message));
    }
  }
}
