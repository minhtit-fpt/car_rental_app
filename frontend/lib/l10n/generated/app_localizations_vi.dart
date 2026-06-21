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

  @override
  String get commonError => 'Đã xảy ra lỗi';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonReset => 'Đặt lại';

  @override
  String get commonApply => 'Áp dụng';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonEdit => 'Sửa';

  @override
  String get commonDelete => 'Xoá';

  @override
  String get commonUser => 'Người dùng';

  @override
  String get roleRenter => 'Người thuê';

  @override
  String get roleOwner => 'Chủ xe';

  @override
  String get profileEdit => 'Chỉnh sửa hồ sơ';

  @override
  String get kycVerified => '✓ KYC Đã xác minh';

  @override
  String get kycPending => '⏳ KYC Đang duyệt';

  @override
  String get kycRejected => '✕ KYC Bị từ chối';

  @override
  String get kycUnverified => '! KYC Chưa xác minh';

  @override
  String get kycUnverifiedShort => 'KYC chưa xác minh';

  @override
  String get vehicleTypeCar => 'Ô tô';

  @override
  String get vehicleTypeMotorbike => 'Xe máy';

  @override
  String get vehicleTypeBicycle => 'Xe đạp';

  @override
  String get vehicleTransmissionAutomatic => 'Tự động';

  @override
  String get vehicleTransmissionManual => 'Số sàn';

  @override
  String get vehicleElectric => 'Điện';

  @override
  String get vehicleFuelGas => 'Xăng';

  @override
  String get vehiclePerDay => '/ngày';

  @override
  String get vehicleAvailable => 'Còn trống';

  @override
  String get vehicleInStock => 'Còn xe';

  @override
  String get vehicleRented => 'Đã thuê';

  @override
  String get vehicleDelivery => 'Giao tận nơi';

  @override
  String get vehicleFindCars => 'Tìm xe';

  @override
  String get vehicleFavoriteError =>
      'Không cập nhật được yêu thích, thử lại sau';

  @override
  String vehicleSeats(int count) {
    return '$count chỗ';
  }

  @override
  String vehicleDoors(int count) {
    return '$count cửa';
  }

  @override
  String get vehicleNoLocation => 'Chưa cập nhật vị trí';

  @override
  String get vehicleNotUpdated => 'Chưa cập nhật';

  @override
  String get vehicleOwnerFallback => 'Chủ xe';

  @override
  String get vehicleMessage => 'Nhắn tin';

  @override
  String get vehicleShare => 'Chia sẻ';

  @override
  String get vehicleBookNow => 'Đặt xe ngay';

  @override
  String get vehicleOwnerMetaSample => ' · 36 chuyến · Phản hồi nhanh';

  @override
  String get vehicleBadgeInstant => '⚡ Đặt nhanh';

  @override
  String get vehicleBadgeElectric => '🔋 Xe điện';

  @override
  String get vehicleBadgeWeekendDiscount => '🏷 −15% cuối tuần';

  @override
  String get vehicleTripRulesTitle => 'Quy định chuyến đi';

  @override
  String get vehicleRuleNoSmoking => 'Không hút thuốc trong xe';

  @override
  String get vehicleRuleNoBulkyGoods => 'Không chở hàng hoá cồng kềnh';

  @override
  String get vehicleRuleReturnOnTime => 'Trả xe đúng giờ, đúng địa điểm';

  @override
  String get vehicleRuleCleanBeforeReturn => 'Vệ sinh xe trước khi trả';

  @override
  String get vehiclePickupLocationTitle => 'Địa điểm nhận xe';

  @override
  String get vehicleFilterAll => 'Tất cả';

  @override
  String get vehicleFilterSaved => '❤️ Đã lưu';

  @override
  String get vehicleFilterInstant => '⚡ Đặt nhanh';

  @override
  String get vehicleFilterAuto => '⚙️ Số tự động';

  @override
  String get vehicleFilterElectric => '🔋 Xe điện';

  @override
  String get vehicleFilter5Seats => '5 chỗ';

  @override
  String get vehicleFilter7Seats => '7+ chỗ';

  @override
  String get vehicleSortPopular => 'Phổ biến nhất';

  @override
  String get vehicleSortPriceLow => 'Giá thấp nhất';

  @override
  String get vehicleSortRatingHigh => 'Đánh giá cao';

  @override
  String get vehicleSortNearest => 'Gần nhất';

  @override
  String vehicleCountMatched(int count) {
    return '$count xe phù hợp';
  }

  @override
  String vehicleCountSaved(int count) {
    return '$count xe đã lưu';
  }

  @override
  String get vehicleListView => 'Danh sách';

  @override
  String get vehicleMapView => 'Xem bản đồ';

  @override
  String get vehicleLocationLabel => 'ĐỊA ĐIỂM';

  @override
  String get vehicleLocationPlaceholder => 'Quận 1, TP. HCM';

  @override
  String get vehicleTimeLabel => 'THỜI GIAN';

  @override
  String get vehicleEmptyTitle => 'Không có xe phù hợp';

  @override
  String get vehicleEmptySubtitle => 'Thử thay đổi bộ lọc hoặc tìm kiếm khác';

  @override
  String get vehicleEmptySavedTitle => 'Chưa có xe nào được lưu';

  @override
  String get vehicleEmptySavedSubtitle =>
      'Bấm vào biểu tượng trái tim trên xe để lưu lại xem sau';

  @override
  String get vehicleListErrorTitle => 'Không tải được danh sách xe';

  @override
  String get vehicleFilterTitle => 'Bộ lọc';

  @override
  String get vehicleFilterMaxPrice => 'Giá tối đa / ngày';

  @override
  String get vehicleFilterMinRating => 'Đánh giá tối thiểu';

  @override
  String get homeGreeting => 'Xin chào, bạn';

  @override
  String get homeGreetingQuestion => 'Hôm nay bạn đi đâu?';

  @override
  String get homeLocationLabel => 'ĐIỂM NHẬN';

  @override
  String get homePickupDateLabel => 'NHẬN XE';

  @override
  String get homeReturnDateLabel => 'TRẢ XE';

  @override
  String get homeSelectDate => 'Chọn ngày';

  @override
  String get homeCityPickerTitle => 'Chọn điểm nhận xe';

  @override
  String get homeExploreByCity => 'Khám phá theo thành phố';

  @override
  String get homeFeaturedTitle => 'Xe nổi bật gần bạn';

  @override
  String get homeSeeAll => 'Xem tất cả';

  @override
  String get homeFeaturedError => 'Không tải được xe nổi bật';

  @override
  String get homeTrustTitle => 'Mỗi chuyến đều có bảo hiểm';

  @override
  String get homeTrustSubtitle =>
      'Đền bù tối đa 200 triệu cho mọi hư hỏng phát sinh.';

  @override
  String get dashboardMyProfile => 'Hồ sơ của tôi';

  @override
  String get dashboardRenterSubtitle => 'Tài khoản & điểm thưởng';

  @override
  String get dashboardActiveRenting => 'Đang Thuê';

  @override
  String get dashboardUpcoming => 'Sắp Tới';

  @override
  String get dashboardTotalTrips => 'Tổng Chuyến';

  @override
  String get dashboardLoyaltyPoints => 'Điểm thưởng';

  @override
  String get unitVehicles => 'xe';

  @override
  String get unitTrips => 'chuyến';

  @override
  String get ownerDashboardTitle => 'Trang chủ Chủ xe';

  @override
  String get ownerDashboardSubtitle =>
      'Quản lý xe cho thuê và chuyến đi của bạn';

  @override
  String get ownerRevenueMonth => 'Doanh thu tháng';

  @override
  String get ownerYourCars => 'Xe của bạn';

  @override
  String get ownerTripsThisMonth => 'Chuyến tháng này';

  @override
  String get ownerMyCarsTitle => 'Xe Của Tôi';

  @override
  String get ownerMyCarsSubtitle => 'Xe bạn đang cho thuê';

  @override
  String get ownerAddCar => 'Thêm xe mới';

  @override
  String get ownerNoCars => 'Bạn chưa đăng xe nào';

  @override
  String ownerPricePerHour(String price) {
    return '$priceđ/giờ';
  }

  @override
  String get ownerStatusReady => 'Sẵn sàng';

  @override
  String get ownerStatusHidden => 'Tạm ẩn';

  @override
  String get ownerDeleteTitle => 'Xoá xe?';

  @override
  String ownerDeleteConfirm(String title) {
    return 'Bạn chắc chắn muốn gỡ \"$title\"?';
  }

  @override
  String get ownerDeleteSuccess => 'Đã xoá xe';
}
