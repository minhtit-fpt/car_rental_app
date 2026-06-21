// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RideVN';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languagePickerTitle => 'Select language';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneRequired => 'Please enter your phone number';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get authLoginTitle => 'Log in';

  @override
  String get authLoginSubtitle =>
      'Enter your phone number and password to continue';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authRegisterNow => 'Register now';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSectionAccount => 'Account information';

  @override
  String get authEmailOptionalLabel => 'Email (optional)';

  @override
  String get authEmailInvalid => 'Invalid email';

  @override
  String get authPasswordHintMin => 'At least 8 characters';

  @override
  String get authPasswordMinLength => 'Password must be at least 8 characters';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authAgreeTermsRequired => 'Please agree to the terms of use';

  @override
  String get authTermsPrefix => 'I agree to the ';

  @override
  String get authTermsOfUse => 'Terms of Use';

  @override
  String get authTermsAnd => ' and ';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authTermsSuffix => ' of RideVN';

  @override
  String get authOtpTitle => 'OTP Verification';

  @override
  String get authOtpSentToPrefix => 'Enter the 6-digit code sent to ';

  @override
  String get authOtpConfirm => 'Confirm';

  @override
  String get authOtpResendInPrefix => 'Resend in ';

  @override
  String authOtpSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get authOtpResend => 'Resend OTP code';

  @override
  String get authOtpDemoHint =>
      'Use code 123456 to test in the demo environment.';

  @override
  String get authOtpInvalid => 'Invalid OTP code. Please try again.';
}
