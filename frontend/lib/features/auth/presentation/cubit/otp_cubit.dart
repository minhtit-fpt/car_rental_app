import 'package:flutter_bloc/flutter_bloc.dart';

/// OTP hiện CHƯA có backend (xem [OtpVerificationScreen]). Đây là cubit mock
/// giữ màn OTP chạy được cho giai đoạn sau (hướng "OTP sau" đã chốt).
sealed class OtpState {
  const OtpState();
}

final class OtpIdle extends OtpState {
  const OtpIdle();
}

final class OtpSending extends OtpState {
  const OtpSending();
}

final class OtpSent extends OtpState {
  const OtpSent(this.phone);
  final String phone;
}

final class OtpVerifying extends OtpState {
  const OtpVerifying();
}

final class OtpVerified extends OtpState {
  const OtpVerified();
}

final class OtpFailure extends OtpState {
  const OtpFailure();
}

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(const OtpIdle());

  /// Mã demo cố định cho tới khi backend OTP được xây.
  static const String _demoCode = '123456';

  Future<void> sendOtp(String phone) async {
    emit(const OtpSending());
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    emit(OtpSent(phone));
  }

  Future<void> verifyOtp(String code) async {
    emit(const OtpVerifying());
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (code == _demoCode) {
      emit(const OtpVerified());
    } else {
      emit(const OtpFailure());
    }
  }
}
