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

  @override
  String get commonNo => 'Không';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get bookingStatusPendingPayment => 'Chờ thanh toán';

  @override
  String get bookingStatusConfirmed => 'Đã xác nhận';

  @override
  String get bookingStatusInProgress => 'Đang thuê';

  @override
  String get bookingStatusCompleted => 'Hoàn thành';

  @override
  String get bookingStatusCancelled => 'Đã huỷ';

  @override
  String get tripsTitle => 'Chuyến của tôi';

  @override
  String get tripsSubtitle => 'Quản lý các đơn đặt xe';

  @override
  String get tripsEmpty => 'Bạn chưa có chuyến nào.';

  @override
  String tripsOrderNumber(String id) {
    return 'Đơn #$id';
  }

  @override
  String get tripsCancelling => 'Đang huỷ...';

  @override
  String get tripsCancel => 'Huỷ đơn';

  @override
  String get tripsCancelTitle => 'Huỷ đơn này?';

  @override
  String get tripsCancelConfirm => 'Bạn chắc chắn muốn huỷ đơn đặt xe này?';

  @override
  String get bookingPickDatesTitle => 'Chọn ngày thuê';

  @override
  String get bookingPickDatesSubtitle => 'Chọn thời gian bắt đầu và kết thúc';

  @override
  String get bookingRentalPeriod => 'Thời gian thuê';

  @override
  String get bookingPickupDateLabel => 'Ngày nhận xe';

  @override
  String get bookingReturnDateLabel => 'Ngày trả xe';

  @override
  String get bookingChangeDate => 'Thay đổi ngày';

  @override
  String bookingDays(int count) {
    return '$count ngày';
  }

  @override
  String get bookingDelivery => 'Giao xe tận nơi';

  @override
  String get bookingDeliveryAddressHint => 'Nhập địa chỉ nhận xe...';

  @override
  String get bookingEstimatedCost => 'Chi phí dự kiến';

  @override
  String bookingRentalLine(String price, int days) {
    return '${price}K × $days ngày';
  }

  @override
  String get bookingDeliveryFeeLabel => 'Phí giao xe';

  @override
  String get bookingInsuranceLabel => 'Bảo hiểm (5%)';

  @override
  String get bookingTotal => 'Tổng cộng';

  @override
  String get bookingConfirmTitle => 'Xác nhận đặt xe';

  @override
  String get bookingConfirmSubtitle => 'Kiểm tra thông tin trước khi đặt';

  @override
  String get bookingFailed => 'Đặt xe thất bại';

  @override
  String get bookingConfirmAndPay => 'Xác nhận & Thanh toán';

  @override
  String get bookingTermsNote =>
      'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của RideVN.';

  @override
  String get bookingTripDetails => 'Chi tiết chuyến đi';

  @override
  String get bookingPickup => 'Nhận xe';

  @override
  String get bookingReturn => 'Trả xe';

  @override
  String get bookingDuration => 'Thời gian';

  @override
  String get bookingDeliveryTo => 'Giao xe tại';

  @override
  String get bookingDeliveryAddressFallback => 'Địa chỉ giao xe';

  @override
  String bookingRentalCarLine(String price, int days) {
    return 'Thuê xe (${price}K × $days ngày)';
  }

  @override
  String get bookingDeliveryShort => 'Giao xe';

  @override
  String get bookingServiceFee => 'Phí dịch vụ (3%)';

  @override
  String get bookingTotalPayment => 'Tổng thanh toán';

  @override
  String get bookingDepositTitle => 'Đặt cọc & Hủy chuyến';

  @override
  String get bookingDepositBody =>
      'Đặt cọc 30% khi xác nhận. Hoàn 100% nếu hủy trước 24h nhận xe.';

  @override
  String get contractTitle => 'Hợp đồng điện tử';

  @override
  String get contractSubtitle => 'Đọc kỹ và ký hợp đồng';

  @override
  String get contractHeading => 'Hợp đồng thuê xe';

  @override
  String contractCode(String code) {
    return 'Mã hợp đồng: $code';
  }

  @override
  String get contractPartiesTitle => 'I. CÁC BÊN THAM GIA';

  @override
  String get contractPartiesBody =>
      '• Bên A (Chủ xe): Được xác minh qua hệ thống KYC RideVN\n• Bên B (Người thuê): Đã hoàn tất xác minh danh tính';

  @override
  String get contractVehicleTitle => 'II. THÔNG TIN XE';

  @override
  String get contractVehicleBody =>
      'Xe được giao đúng tình trạng đã mô tả. Người thuê có trách nhiệm kiểm tra xe trước khi nhận và xác nhận trong ứng dụng.';

  @override
  String get contractTermsTitle => 'III. ĐIỀU KHOẢN SỬ DỤNG';

  @override
  String get contractTermsBody =>
      '• Không sử dụng xe vào mục đích trái pháp luật\n• Không cho người khác lái xe khi chưa được chủ xe đồng ý\n• Trả xe đúng thời hạn, đúng địa điểm thỏa thuận\n• Bảo quản xe cẩn thận, không tự ý sửa chữa';

  @override
  String get contractCompensationTitle => 'IV. BỒI THƯỜNG THIỆT HẠI';

  @override
  String get contractCompensationBody =>
      'Mọi thiệt hại nằm ngoài phạm vi bảo hiểm sẽ do Bên B chịu trách nhiệm bồi thường theo định giá của bên thứ ba được chỉ định.';

  @override
  String get contractAgree =>
      'Tôi đã đọc kỹ và đồng ý với tất cả điều khoản trong hợp đồng thuê xe này.';

  @override
  String get contractSign => 'Ký hợp đồng';

  @override
  String get activeTripTitle => 'Chuyến đi đang diễn ra';

  @override
  String get activeTripSubtitle => 'Quản lý chuyến đi của bạn';

  @override
  String get activeTripReturn => 'Trả xe';

  @override
  String get activeTripEmergency => 'Hỗ trợ khẩn cấp';

  @override
  String get activeTripReturnTitle => 'Xác nhận trả xe?';

  @override
  String get activeTripReturnBody =>
      'Bạn xác nhận đã trả xe và kết thúc chuyến đi này?';

  @override
  String get activeTripNotYet => 'Chưa';

  @override
  String get activeTripRunning => '🟢 Đang chạy';

  @override
  String get activeTripRemaining => 'Còn lại';

  @override
  String get activeTripProgress => 'Tiến trình chuyến đi';

  @override
  String activeTripDaysProgress(int elapsed, int total) {
    return '$elapsed/$total ngày';
  }

  @override
  String get activeTripVehicleInfo => 'Thông tin xe';

  @override
  String activeTripLicensePlate(String plate) {
    return 'Biển số: $plate';
  }

  @override
  String get activeTripCall => 'Gọi';

  @override
  String get activeTripCallOwner => 'Gọi chủ xe';

  @override
  String get activeTripMap => 'Bản đồ';

  @override
  String get activeTripPhoto => 'Chụp ảnh';

  @override
  String get activeTripReport => 'Báo hỏng';
}
