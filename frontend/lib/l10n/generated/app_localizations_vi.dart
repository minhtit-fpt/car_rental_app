// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'RideVN';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languagePickerTitle => 'Chọn ngôn ngữ';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get phoneRequired => 'Vui lòng nhập số điện thoại';

  @override
  String get phoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get authLoginTitle => 'Đăng nhập';

  @override
  String get authLoginSubtitle => 'Nhập số điện thoại và mật khẩu để tiếp tục';

  @override
  String get authNoAccount => 'Chưa có tài khoản? ';

  @override
  String get authRegisterNow => 'Đăng ký ngay';

  @override
  String get authRegisterTitle => 'Tạo tài khoản';

  @override
  String get authRegisterSectionAccount => 'Thông tin tài khoản';

  @override
  String get authEmailOptionalLabel => 'Email (tuỳ chọn)';

  @override
  String get authEmailInvalid => 'Email không hợp lệ';

  @override
  String get authPasswordHintMin => 'Tối thiểu 8 ký tự';

  @override
  String get authPasswordMinLength => 'Mật khẩu phải tối thiểu 8 ký tự';

  @override
  String get authConfirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get authConfirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get authPasswordMismatch => 'Mật khẩu nhập lại không khớp';

  @override
  String get authAlreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get authAgreeTermsRequired => 'Vui lòng đồng ý với điều khoản sử dụng';

  @override
  String get authTermsPrefix => 'Tôi đồng ý với ';

  @override
  String get authTermsOfUse => 'Điều khoản sử dụng';

  @override
  String get authTermsAnd => ' và ';

  @override
  String get authPrivacyPolicy => 'Chính sách bảo mật';

  @override
  String get authTermsSuffix => ' của RideVN';

  @override
  String get authOtpTitle => 'Xác thực OTP';

  @override
  String get authOtpSentToPrefix => 'Nhập mã 6 số đã gửi tới ';

  @override
  String get authOtpConfirm => 'Xác nhận';

  @override
  String get authOtpResendInPrefix => 'Gửi lại sau ';

  @override
  String authOtpSeconds(int seconds) {
    return '$seconds giây';
  }

  @override
  String get authOtpResend => 'Gửi lại mã OTP';

  @override
  String get authOtpDemoHint => 'Dùng mã 123456 để test trong môi trường demo.';

  @override
  String get authOtpInvalid => 'Mã OTP không đúng. Vui lòng thử lại.';
}
