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
  String get kycPending => 'Chờ xử lý';

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
  String vehicleShareMessage(String title, String price, String link) {
    return 'Thuê $title — chỉ $price VNĐ/ngày trên RideVN 🚗\n$link';
  }

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
  String get ownerChatTooltip => 'Tin nhắn với khách';

  @override
  String get ownerCarNoRating => 'Chưa có';

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
  String ownerPricePerDay(String price) {
    return '$priceđ/ngày';
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
  String get bookingStatusAwaitingOwner => 'Chờ chủ xe xác nhận';

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
  String get tripsPay => 'Thanh toán';

  @override
  String get tripsCancelTitle => 'Huỷ đơn này?';

  @override
  String get tripsCancelConfirm => 'Bạn chắc chắn muốn huỷ đơn đặt xe này?';

  @override
  String get tripsDetailTitle => 'Chi tiết chuyến';

  @override
  String get tripsDetailSubtitle => 'Thông tin đầy đủ của đơn';

  @override
  String tripsBookedOn(String date) {
    return 'Đặt ngày $date';
  }

  @override
  String get tripsInspectionCta => 'Kiểm tra xe (AI)';

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
  String get bookingPriceBreakdownTitle => 'Chi tiết giá';

  @override
  String bookingBasePrice(int days) {
    return 'Giá gốc ($days ngày)';
  }

  @override
  String get bookingDynamicPriceNote =>
      'Giá tự điều chỉnh theo thời điểm và nhu cầu thuê.';

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

  @override
  String get reportSheetTitle => 'Báo cáo sự cố';

  @override
  String get reportSheetSubtitle =>
      'Thêm ảnh sự cố (tuỳ chọn) rồi nhắn cho đội hỗ trợ.';

  @override
  String get reportCamera => 'Máy ảnh';

  @override
  String get reportGallery => 'Thư viện';

  @override
  String get reportPhotoAttached => 'Đã đính kèm ảnh';

  @override
  String get reportRemovePhoto => 'Gỡ';

  @override
  String get reportContinueToSupport => 'Nhắn hỗ trợ';

  @override
  String get emergencySheetTitle => 'Khẩn cấp';

  @override
  String get emergencySheetSubtitle =>
      'Chạm để sao chép số, rồi gọi từ điện thoại của bạn.';

  @override
  String get emergencyPolice => 'Cảnh sát';

  @override
  String get emergencyFire => 'Cứu hoả';

  @override
  String get emergencyAmbulance => 'Cấp cứu';

  @override
  String emergencyNumberCopied(String label, String number) {
    return 'Đã sao chép số $label $number';
  }

  @override
  String get emergencyTipsTitle => 'Mẹo an toàn';

  @override
  String get emergencyTipSafePlace =>
      'Di chuyển đến nơi an toàn trước khi gọi.';

  @override
  String get emergencyTipShareLocation =>
      'Chia sẻ vị trí trực tiếp cho người bạn tin tưởng.';

  @override
  String get emergencyTipNoteDetails =>
      'Ghi lại biển số xe, vị trí và diễn biến sự việc.';

  @override
  String get commonYes => 'Có';

  @override
  String get vehicleTransmissionNone => 'Không áp dụng';

  @override
  String get ownerCalendarTitle => 'Lịch xe';

  @override
  String get ownerCalendarSubtitle => 'Quản lý lịch cho thuê';

  @override
  String get ownerPendingApproval => 'Chờ duyệt';

  @override
  String get ownerToday => 'Hôm nay';

  @override
  String get ownerNeedsResponse => 'Cần phản hồi';

  @override
  String get ownerNoPendingRequests => 'Không có yêu cầu nào đang chờ';

  @override
  String get ownerReject => 'Từ chối';

  @override
  String get ownerApprove => 'Chấp nhận';

  @override
  String get ownerRequestDetailTitle => 'Chi tiết yêu cầu';

  @override
  String get ownerRequestDetailSubtitle => 'Xem xét và xử lý yêu cầu thuê xe';

  @override
  String get ownerNoRequestData => 'Không có dữ liệu yêu cầu';

  @override
  String get ownerRequestApproved => 'Đã chấp nhận yêu cầu';

  @override
  String get ownerRequestRejected => 'Đã từ chối yêu cầu';

  @override
  String ownerSentOn(String date) {
    return 'Gửi $date';
  }

  @override
  String ownerHours(int count) {
    return '$count giờ';
  }

  @override
  String get ownerTotalRental => 'Tổng tiền thuê';

  @override
  String get ownerPlatformFee => 'Phí nền tảng (10%)';

  @override
  String get ownerYouReceive => 'Bạn nhận được';

  @override
  String get ownerProcessing => 'Đang xử lý…';

  @override
  String get ownerApproveRequest => 'Chấp nhận yêu cầu';

  @override
  String get ownerRequestHandled => 'Yêu cầu này đã được xử lý.';

  @override
  String get ownerStatusPendingConfirm => '🟡 Chờ xác nhận';

  @override
  String get ownerStatusConfirmed => '✅ Đã xác nhận';

  @override
  String get ownerStatusInProgress => '🚗 Đang thuê';

  @override
  String get ownerStatusCompleted => '✔ Hoàn tất';

  @override
  String get ownerStatusCancelled => '✖ Đã huỷ';

  @override
  String get ownerStatusUnknown => 'Không rõ';

  @override
  String get ownerRevenueTitle => 'Báo cáo doanh thu';

  @override
  String get ownerRevenueSubtitle => 'Theo dõi thu nhập của bạn';

  @override
  String get ownerIncomeThisMonth => 'Thu nhập tháng này';

  @override
  String ownerPaidTrips(int count) {
    return '$count chuyến đã thanh toán';
  }

  @override
  String get ownerRevenueChart => 'Biểu đồ doanh thu';

  @override
  String get ownerNoRevenue => 'Chưa có doanh thu trong giai đoạn này';

  @override
  String get ownerRecentTransactions => 'Giao dịch gần đây';

  @override
  String get ownerNoTransactions => 'Chưa có giao dịch nào';

  @override
  String get ownerVehicleNameRequired => 'Vui lòng nhập tên xe';

  @override
  String get ownerVehiclePriceInvalid => 'Giá thuê phải lớn hơn 0';

  @override
  String get ownerVehicleCoordsInvalid => 'Toạ độ không hợp lệ';

  @override
  String get ownerVehicleUpdateSuccess => 'Cập nhật xe thành công';

  @override
  String get ownerVehicleCreateSuccess => 'Đăng xe thành công';

  @override
  String get ownerVehicleEditTitle => 'Chỉnh sửa xe';

  @override
  String get ownerVehicleAddTitle => 'Đăng xe mới';

  @override
  String get ownerVehicleEditSubtitle => 'Cập nhật thông tin xe của bạn';

  @override
  String get ownerVehicleAddSubtitle => 'Điền thông tin để đăng xe';

  @override
  String get ownerVehicleSaveChanges => 'Lưu thay đổi';

  @override
  String get ownerVehiclePublish => 'Đăng xe';

  @override
  String get ownerVehiclePhotos => 'Ảnh xe';

  @override
  String get ownerVehiclePhotosHint =>
      'Tối đa 10 ảnh · Ảnh đầu tiên là ảnh bìa';

  @override
  String get ownerVehicleAddPhoto => 'Thêm ảnh';

  @override
  String get ownerVehicleBasicInfo => 'Thông tin cơ bản';

  @override
  String get ownerVehicleName => 'Tên xe';

  @override
  String get ownerVehicleNameHint => 'VD: Toyota Camry 2024';

  @override
  String get ownerVehiclePricePerDay => 'Giá/ngày (VNĐ)';

  @override
  String get ownerVehiclePriceHint => 'VD: 50000';

  @override
  String get ownerVehicleType => 'Loại xe';

  @override
  String get ownerVehicleLocation => 'Vị trí xe';

  @override
  String get ownerVehicleLat => 'Vĩ độ (lat)';

  @override
  String get ownerVehicleLatHint => 'VD: 21.0278';

  @override
  String get ownerVehicleLng => 'Kinh độ (lng)';

  @override
  String get ownerVehicleLngHint => 'VD: 105.8342';

  @override
  String get ownerVehicleMapSoon =>
      'Chọn vị trí trên bản đồ sẽ sớm được hỗ trợ.';

  @override
  String get ownerVehicleMapPickHint => 'Chạm vào bản đồ để đặt điểm nhận xe.';

  @override
  String get ownerVehicleSpecs => 'Thông số kỹ thuật';

  @override
  String get ownerVehicleSpecsHint =>
      'Có thể bỏ trống nếu không áp dụng (vd: xe máy, xe đạp).';

  @override
  String get ownerVehicleSeats => 'Số chỗ';

  @override
  String get ownerVehicleSeatsHint => 'VD: 5';

  @override
  String get ownerVehicleDoors => 'Số cửa';

  @override
  String get ownerVehicleDoorsHint => 'VD: 4';

  @override
  String get ownerVehicleTransmission => 'Hộp số';

  @override
  String get ownerVehicleCity => 'Thành phố';

  @override
  String get ownerVehicleCityHint => 'VD: TP. HCM';

  @override
  String get ownerVehicleDescription => 'Mô tả xe';

  @override
  String get ownerVehicleDescriptionHint =>
      'Mô tả tình trạng, tiện ích nổi bật của xe...';

  @override
  String get ownerVehicleOptions => 'Tùy chọn';

  @override
  String get ownerVehicleEv => 'Xe điện (EV)';

  @override
  String get ownerVehicleEvSubtitle => 'Hiển thị badge EV trên listing';

  @override
  String get ownerVehicleDeliverySubtitle =>
      'Cho phép giao xe đến địa chỉ khách';

  @override
  String get commonComingSoon => 'Sắp có';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLogout => 'Đăng xuất';

  @override
  String get settingsLogoutConfirm =>
      'Bạn có chắc muốn đăng xuất khỏi tài khoản này?';

  @override
  String get settingsSectionPreferences => 'Tuỳ chỉnh';

  @override
  String get settingsSectionAccount => 'Tài khoản';

  @override
  String get settingsSectionOther => 'Khác';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsNotificationsSubtitle => 'Nhận thông báo đẩy';

  @override
  String get settingsDarkMode => 'Giao diện tối';

  @override
  String get themePickerTitle => 'Chế độ hiển thị';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsChangePassword => 'Đổi mật khẩu';

  @override
  String get settingsDeleteAccount => 'Xoá tài khoản';

  @override
  String get settingsAbout => 'Về ứng dụng';

  @override
  String settingsAboutSubtitle(String version) {
    return 'RideVN · Phiên bản $version';
  }

  @override
  String settingsVersionLabel(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsTermsPolicies => 'Điều khoản & chính sách';

  @override
  String get termsScreenTitle => 'Điều khoản & Chính sách';

  @override
  String get termsUpdatedLabel => 'Cập nhật lần cuối tháng 6/2026';

  @override
  String get termsIntroHeading => '1. Chấp thuận điều khoản';

  @override
  String get termsIntroBody =>
      'Khi tạo tài khoản hoặc sử dụng RideVN, bạn đồng ý với các Điều khoản & Chính sách này. Nếu không đồng ý, vui lòng ngừng sử dụng ứng dụng. Chúng tôi có thể cập nhật điều khoản theo thời gian và sẽ ghi ngày sửa đổi gần nhất ở phía trên.';

  @override
  String get termsAccountHeading => '2. Tài khoản của bạn';

  @override
  String get termsAccountBody =>
      'Bạn chịu trách nhiệm bảo mật thông tin đăng nhập và mọi hoạt động dưới tài khoản của mình. Bạn cần cung cấp thông tin chính xác và hoàn tất xác minh danh tính (KYC) trước khi thuê hoặc đăng xe. Một tài khoản có thể đồng thời là người thuê và chủ xe.';

  @override
  String get termsBookingHeading => '3. Đặt xe & thanh toán';

  @override
  String get termsBookingBody =>
      'Mỗi lượt đặt xe là hợp đồng giữa người thuê và chủ xe; RideVN là bên hỗ trợ giao dịch. Giá thuê, tiền cọc và các điều chỉnh giờ cao điểm được hiển thị trước khi bạn xác nhận. Thanh toán được xử lý qua các cổng được hỗ trợ. Điều kiện huỷ và hoàn tiền phụ thuộc vào thời điểm huỷ và chính sách của chủ xe hiển thị khi thanh toán.';

  @override
  String get termsConductHeading => '4. Sử dụng xe & ứng xử';

  @override
  String get termsConductBody =>
      'Người thuê phải có giấy phép lái xe hợp lệ, lái xe đúng luật và trả xe đúng giờ, đúng tình trạng và đúng địa điểm đã thoả thuận. Chủ xe phải giữ xe đủ điều kiện lưu thông, có bảo hiểm và mô tả chính xác. Nghiêm cấm sử dụng vào mục đích trái pháp luật, cho thuê lại hoặc tháo gỡ thiết bị định vị/an toàn.';

  @override
  String get termsPrivacyHeading => '5. Quyền riêng tư & dữ liệu';

  @override
  String get termsPrivacyBody =>
      'Chúng tôi thu thập dữ liệu cần thiết để vận hành dịch vụ — thông tin tài khoản, giấy tờ KYC, vị trí dùng để tìm xe gần, lịch sử đặt xe và thanh toán. Giấy tờ KYC được lưu riêng tư, không bao giờ công khai. Chúng tôi không bán dữ liệu cá nhân của bạn. Bạn có thể yêu cầu truy cập hoặc xoá dữ liệu tài khoản trong phần Cài đặt.';

  @override
  String get termsContactHeading => '6. Liên hệ';

  @override
  String get termsContactBody =>
      'Có thắc mắc về điều khoản hoặc dữ liệu của bạn? Liên hệ đội hỗ trợ qua chat trong ứng dụng, hoặc email support@ridevn.app.';

  @override
  String get changePasswordCurrent => 'Mật khẩu hiện tại';

  @override
  String get changePasswordNew => 'Mật khẩu mới';

  @override
  String get changePasswordConfirm => 'Xác nhận mật khẩu mới';

  @override
  String get changePasswordSubmit => 'Cập nhật mật khẩu';

  @override
  String get changePasswordSuccess => 'Đã đổi mật khẩu';

  @override
  String get changePasswordFillAll => 'Vui lòng nhập đầy đủ các trường';

  @override
  String get changePasswordTooShort => 'Mật khẩu mới phải tối thiểu 8 ký tự';

  @override
  String get changePasswordMismatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get changePasswordSameAsCurrent =>
      'Mật khẩu mới phải khác mật khẩu hiện tại';

  @override
  String get deleteAccountWarning =>
      'Hành động này sẽ xoá vĩnh viễn tài khoản và toàn bộ dữ liệu liên quan — chuyến đi, xe, đánh giá và tin nhắn. Không thể hoàn tác.';

  @override
  String get deleteAccountConfirmCheckbox =>
      'Tôi hiểu hành động này là vĩnh viễn.';

  @override
  String get deleteAccountConfirmButton => 'Xoá tài khoản của tôi';

  @override
  String get profileEditSubtitle => 'Cập nhật thông tin cá nhân';

  @override
  String get profileUpdateSuccess => 'Đã cập nhật hồ sơ';

  @override
  String get profileUpdateFailed => 'Cập nhật thất bại';

  @override
  String get profileChangeAvatar => 'Đổi ảnh đại diện';

  @override
  String get profilePersonalInfo => 'Thông tin cá nhân';

  @override
  String get profileFullName => 'Họ và tên';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhoneReadonly => 'Không thể thay đổi số điện thoại';

  @override
  String get profileBio => 'Giới thiệu bản thân';

  @override
  String get profileBioHint => 'Chia sẻ một chút về bản thân...';

  @override
  String commonComingSoonSnack(String feature) {
    return '$feature sắp có';
  }

  @override
  String get navFindCar => 'Tìm xe';

  @override
  String get navVehicles => 'Xe';

  @override
  String get navTrips => 'Chuyến';

  @override
  String get navMap => 'Bản đồ';

  @override
  String get navMe => 'Tôi';

  @override
  String get shellAccountTitle => 'Tài khoản';

  @override
  String get trackingTitle => 'Vị trí xe';

  @override
  String get trackingWaiting => 'Đang lấy vị trí xe…';

  @override
  String trackingSpeed(int kmh) {
    return '$kmh km/h';
  }

  @override
  String get trackingViewButton => 'Xem vị trí xe';

  @override
  String get adminActiveTripsTitle => 'Xe đang trong chuyến';

  @override
  String get adminActiveTripsEmpty => 'Không có xe nào đang chạy.';

  @override
  String get mapScreenTitle => 'Xe quanh đây';

  @override
  String mapNearbyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count xe quanh đây',
      one: '1 xe quanh đây',
      zero: 'Không có xe quanh đây',
    );
    return '$_temp0';
  }

  @override
  String get mapEmptyTitle => 'Chưa có xe quanh đây';

  @override
  String get mapEmptySubtitle =>
      'Thử di chuyển bản đồ hoặc mở rộng khu vực tìm kiếm.';

  @override
  String get mapMyLocationTooltip => 'Vị trí của tôi';

  @override
  String get mapRefreshTooltip => 'Tải lại';

  @override
  String get mapOpenInTab => 'Xem bản đồ đầy đủ';

  @override
  String get notifMarkAllRead => 'Đọc tất cả';

  @override
  String get notifEmpty => 'Chưa có thông báo nào';

  @override
  String get notifDetailTitle => 'Chi tiết thông báo';

  @override
  String get notifViewTrip => 'Xem chuyến của tôi';

  @override
  String get loyaltySubtitle => 'Tích lũy điểm cho mỗi chuyến đi';

  @override
  String get loyaltyPointsUnit => 'điểm thưởng';

  @override
  String get loyaltyTier => 'Hạng';

  @override
  String loyaltyPointsToNext(int points, String tier) {
    return '$points điểm nữa lên $tier';
  }

  @override
  String get loyaltyHistory => 'Lịch sử điểm';

  @override
  String get loyaltyNoHistory => 'Chưa có lịch sử điểm';

  @override
  String loyaltyPointsShort(int points) {
    return '$points điểm';
  }

  @override
  String get communityTitle => 'Cộng đồng';

  @override
  String get communityLatestStories => 'Câu chuyện mới nhất';

  @override
  String get communityEmpty => 'Chưa có câu chuyện nào';

  @override
  String get communityShareTrip => 'Chia sẻ chuyến đi';

  @override
  String get communityComposerHint => 'Kể về chuyến đi của bạn...';

  @override
  String get communityPost => 'Đăng';

  @override
  String get communityBannerPrompt => 'Chia sẻ chuyến đi của bạn...';

  @override
  String get chatTitle => 'Tin nhắn';

  @override
  String get chatEmpty => 'Chưa có cuộc trò chuyện nào';

  @override
  String get chatStartConversation => 'Bắt đầu trò chuyện';

  @override
  String get chatNoMessages => 'Chưa có tin nhắn nào';

  @override
  String get chatInputHint => 'Nhắn tin...';

  @override
  String get chatYesterday => 'Hôm qua';

  @override
  String get chatPartnerFallback => 'Hội thoại';

  @override
  String get chatWithOwner => 'Nhắn tin với chủ xe';

  @override
  String get paymentTitle => 'Thanh toán';

  @override
  String get paymentSubtitle => 'Chọn phương thức thanh toán';

  @override
  String paymentPayAmount(String amount) {
    return 'Thanh toán $amount VNĐ';
  }

  @override
  String get paymentAmount => 'Số tiền thanh toán';

  @override
  String get paymentSslBadge => '🔒  Thanh toán bảo mật SSL';

  @override
  String get paymentMethod => 'Phương thức thanh toán';

  @override
  String get paymentMethodVnpayDesc => 'Ví VNPay & ATM nội địa';

  @override
  String get paymentMethodMomoDesc => 'Ví điện tử MoMo';

  @override
  String get paymentMethodZalopayDesc => 'Ví điện tử ZaloPay';

  @override
  String get paymentMethodCard => 'Thẻ quốc tế';

  @override
  String get paymentSslEncryption => 'Giao dịch được mã hóa 256-bit SSL';

  @override
  String get paymentVnpayTitle => 'Thanh toán VNPay';

  @override
  String get paymentGatewayLoadError =>
      'Không tải được cổng thanh toán.\nKiểm tra kết nối mạng rồi thử lại.';

  @override
  String get commonClose => 'Đóng';

  @override
  String get paymentResultSuccessTitle => 'Thanh toán thành công!';

  @override
  String get paymentResultFailTitle => 'Thanh toán thất bại';

  @override
  String get paymentResultSuccessBody =>
      'Đã thanh toán. Đơn đang chờ chủ xe xác nhận.\nBạn sẽ được thông báo ngay khi có kết quả.';

  @override
  String get paymentResultFailBody =>
      'Giao dịch không thành công.\nVui lòng thử lại hoặc chọn phương thức khác.';

  @override
  String get paymentViewTrip => 'Xem chuyến đi';

  @override
  String get paymentBackHome => 'Về trang chủ';

  @override
  String get paymentAmountLabel => 'Số tiền';

  @override
  String get paymentTxnId => 'Mã giao dịch';

  @override
  String get paymentTime => 'Thời gian';

  @override
  String get paymentStatusLabel => 'Trạng thái';

  @override
  String get paymentStatusSuccess => '✅ Thành công';

  @override
  String get reviewTitle => 'Đánh giá chuyến đi';

  @override
  String get reviewSubtitle => 'Chia sẻ trải nghiệm của bạn';

  @override
  String get reviewVehicleQuality => 'Chất lượng xe';

  @override
  String get reviewTagClean => 'Xe sạch';

  @override
  String get reviewTagOnTime => 'Đúng giờ';

  @override
  String get reviewTagFriendlyOwner => 'Chủ xe thân thiện';

  @override
  String get reviewTagAsDescribed => 'Xe đúng mô tả';

  @override
  String get reviewTagDelivery => 'Giao xe tận nơi';

  @override
  String get reviewTagFairPrice => 'Giá hợp lý';

  @override
  String get reviewRatingBad => 'Tệ';

  @override
  String get reviewRatingPoor => 'Không ổn';

  @override
  String get reviewRatingOk => 'Bình thường';

  @override
  String get reviewRatingGood => 'Tốt';

  @override
  String get reviewRatingExcellent => 'Xuất sắc';

  @override
  String get reviewCompleted => '✅ Đã hoàn thành';

  @override
  String get reviewHighlights => 'Điểm nổi bật';

  @override
  String get reviewCommentLabel => 'Nhận xét thêm (tùy chọn)';

  @override
  String get reviewCommentHint => 'Chia sẻ trải nghiệm của bạn...';

  @override
  String get reviewSubmit => 'Gửi đánh giá';

  @override
  String get reviewsTitle => 'Đánh giá';

  @override
  String reviewsAboutUser(String name) {
    return 'Đánh giá về $name';
  }

  @override
  String get reviewsAllReceived => 'Tất cả đánh giá nhận được';

  @override
  String get reviewsEmpty => 'Chưa có đánh giá nào';

  @override
  String reviewsCount(int count) {
    return '$count đánh giá';
  }

  @override
  String get reviewsLoadError => 'Không tải được đánh giá. Thử lại sau.';

  @override
  String reviewsViewAll(int count) {
    return 'Xem tất cả $count đánh giá';
  }

  @override
  String get kycTitle => 'Xác minh danh tính';

  @override
  String get kycSubtitle => 'Hoàn thành KYC để thuê và đăng xe';

  @override
  String get kycStepCccd => 'CCCD / Căn cước công dân';

  @override
  String get kycStepLicense => 'Bằng lái xe';

  @override
  String get kycStepSelfie => 'Ảnh chân dung (selfie)';

  @override
  String get kycSelfieHint => 'Chụp thẳng mặt, ánh sáng đầy đủ';

  @override
  String get kycSubmit => 'Gửi xác minh';

  @override
  String get kycInfoBanner =>
      'Thông tin của bạn được mã hoá và bảo mật. Chỉ dùng để xác minh danh tính.';

  @override
  String get kycUploaded => 'Đã tải lên';

  @override
  String get kycUploading => 'Đang tải...';

  @override
  String get kycTapToUpload => 'Chạm để tải ảnh';

  @override
  String get kycStatusTitle => 'Trạng thái KYC';

  @override
  String get kycStatusSubtitle => 'Xác minh danh tính của bạn';

  @override
  String get kycStatusUnverifiedTitle => 'Chưa nộp hồ sơ';

  @override
  String get kycStatusUnverifiedSubtitle =>
      'Bạn chưa gửi hồ sơ xác minh.\nNộp CCCD, bằng lái và ảnh chân dung để bắt đầu.';

  @override
  String get kycStatusPendingTitle => 'Đang chờ xét duyệt';

  @override
  String get kycStatusPendingSubtitle =>
      'Hồ sơ của bạn đang được xem xét.\nThường mất 1–2 ngày làm việc.';

  @override
  String get kycStatusApprovedTitle => 'Đã xác minh';

  @override
  String get kycStatusApprovedSubtitle =>
      'Tài khoản của bạn đã được xác minh.\nBạn có thể thuê xe ngay.';

  @override
  String get kycStatusRejectedTitle => 'Xác minh thất bại';

  @override
  String get kycStatusRejectedSubtitle =>
      'Hồ sơ bị từ chối. Vui lòng\nnộp lại với ảnh rõ ràng hơn.';

  @override
  String get kycTimelineTitle => 'Tiến trình xét duyệt';

  @override
  String get kycStepSubmit => 'Nộp hồ sơ';

  @override
  String get kycStepReview => 'Đang xét duyệt';

  @override
  String get kycStepComplete => 'Xác minh hoàn tất';

  @override
  String get kycStepRejected => 'Từ chối';

  @override
  String get kycNotSubmitted => 'Chưa nộp';

  @override
  String get kycProcessing => 'Đang xử lý...';

  @override
  String get kycRejectReason => 'Lý do từ chối';

  @override
  String get kycSubmitDocs => 'Nộp hồ sơ KYC';

  @override
  String get kycFindCarNow => 'Tìm xe ngay';

  @override
  String get kycResubmit => 'Nộp lại hồ sơ';

  @override
  String get kycContactSupport => 'Liên hệ hỗ trợ';
}
