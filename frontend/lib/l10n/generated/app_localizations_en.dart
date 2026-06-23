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

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUser => 'User';

  @override
  String get roleRenter => 'Renter';

  @override
  String get roleOwner => 'Owner';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get kycVerified => '✓ KYC Verified';

  @override
  String get kycPending => 'Pending';

  @override
  String get kycRejected => '✕ KYC Rejected';

  @override
  String get kycUnverified => '! KYC Not verified';

  @override
  String get kycUnverifiedShort => 'KYC not verified';

  @override
  String get vehicleTypeCar => 'Car';

  @override
  String get vehicleTypeMotorbike => 'Motorbike';

  @override
  String get vehicleTypeBicycle => 'Bicycle';

  @override
  String get vehicleTransmissionAutomatic => 'Automatic';

  @override
  String get vehicleTransmissionManual => 'Manual';

  @override
  String get vehicleElectric => 'Electric';

  @override
  String get vehicleFuelGas => 'Petrol';

  @override
  String get vehiclePerDay => '/day';

  @override
  String get vehicleAvailable => 'Available';

  @override
  String get vehicleInStock => 'Available';

  @override
  String get vehicleRented => 'Rented';

  @override
  String get vehicleDelivery => 'Delivery';

  @override
  String get vehicleFindCars => 'Find a car';

  @override
  String get vehicleFavoriteError =>
      'Couldn\'t update favorites, please try again later';

  @override
  String vehicleSeats(int count) {
    return '$count seats';
  }

  @override
  String vehicleDoors(int count) {
    return '$count doors';
  }

  @override
  String get vehicleNoLocation => 'Location not updated';

  @override
  String get vehicleNotUpdated => 'Not updated';

  @override
  String get vehicleOwnerFallback => 'Owner';

  @override
  String get vehicleMessage => 'Message';

  @override
  String get vehicleShare => 'Share';

  @override
  String vehicleShareMessage(String title, String price, String link) {
    return 'Check out $title — only $price VNĐ/day on RideVN 🚗\n$link';
  }

  @override
  String get vehicleBookNow => 'Book now';

  @override
  String get vehicleOwnerMetaSample => ' · 36 trips · Fast response';

  @override
  String get vehicleBadgeInstant => '⚡ Instant book';

  @override
  String get vehicleBadgeElectric => '🔋 Electric';

  @override
  String get vehicleBadgeWeekendDiscount => '🏷 −15% weekends';

  @override
  String get vehicleTripRulesTitle => 'Trip rules';

  @override
  String get vehicleRuleNoSmoking => 'No smoking in the car';

  @override
  String get vehicleRuleNoBulkyGoods => 'No bulky cargo';

  @override
  String get vehicleRuleReturnOnTime => 'Return on time, at the right place';

  @override
  String get vehicleRuleCleanBeforeReturn => 'Clean the car before returning';

  @override
  String get vehiclePickupLocationTitle => 'Pick-up location';

  @override
  String get vehicleFilterAll => 'All';

  @override
  String get vehicleFilterSaved => '❤️ Saved';

  @override
  String get vehicleFilterInstant => '⚡ Instant book';

  @override
  String get vehicleFilterAuto => '⚙️ Automatic';

  @override
  String get vehicleFilterElectric => '🔋 Electric';

  @override
  String get vehicleFilter5Seats => '5 seats';

  @override
  String get vehicleFilter7Seats => '7+ seats';

  @override
  String get vehicleSortPopular => 'Most popular';

  @override
  String get vehicleSortPriceLow => 'Lowest price';

  @override
  String get vehicleSortRatingHigh => 'Highest rated';

  @override
  String get vehicleSortNearest => 'Nearest';

  @override
  String vehicleCountMatched(int count) {
    return '$count matching cars';
  }

  @override
  String vehicleCountSaved(int count) {
    return '$count saved cars';
  }

  @override
  String get vehicleListView => 'List';

  @override
  String get vehicleMapView => 'View map';

  @override
  String get vehicleLocationLabel => 'LOCATION';

  @override
  String get vehicleLocationPlaceholder => 'District 1, HCMC';

  @override
  String get vehicleTimeLabel => 'TIME';

  @override
  String get vehicleEmptyTitle => 'No matching cars';

  @override
  String get vehicleEmptySubtitle =>
      'Try changing the filters or another search';

  @override
  String get vehicleEmptySavedTitle => 'No saved cars yet';

  @override
  String get vehicleEmptySavedSubtitle =>
      'Tap the heart icon on a car to save it for later';

  @override
  String get vehicleListErrorTitle => 'Couldn\'t load the car list';

  @override
  String get vehicleFilterTitle => 'Filters';

  @override
  String get vehicleFilterMaxPrice => 'Max price / day';

  @override
  String get vehicleFilterMinRating => 'Minimum rating';

  @override
  String get homeGreeting => 'Hello there';

  @override
  String get homeGreetingQuestion => 'Where are you going today?';

  @override
  String get homeLocationLabel => 'PICK-UP POINT';

  @override
  String get homePickupDateLabel => 'PICK-UP';

  @override
  String get homeReturnDateLabel => 'RETURN';

  @override
  String get homeSelectDate => 'Select date';

  @override
  String get homeCityPickerTitle => 'Select pick-up location';

  @override
  String get homeExploreByCity => 'Explore by city';

  @override
  String get homeFeaturedTitle => 'Featured cars near you';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeFeaturedError => 'Couldn\'t load featured cars';

  @override
  String get homeTrustTitle => 'Every trip is insured';

  @override
  String get homeTrustSubtitle =>
      'Up to 200 million VND coverage for any damage.';

  @override
  String get dashboardMyProfile => 'My profile';

  @override
  String get dashboardRenterSubtitle => 'Account & loyalty points';

  @override
  String get dashboardActiveRenting => 'Renting';

  @override
  String get dashboardUpcoming => 'Upcoming';

  @override
  String get dashboardTotalTrips => 'Total trips';

  @override
  String get dashboardLoyaltyPoints => 'Loyalty points';

  @override
  String get unitVehicles => 'cars';

  @override
  String get unitTrips => 'trips';

  @override
  String get ownerDashboardTitle => 'Owner home';

  @override
  String get ownerDashboardSubtitle => 'Manage your rental cars and trips';

  @override
  String get ownerRevenueMonth => 'Monthly revenue';

  @override
  String get ownerYourCars => 'Your cars';

  @override
  String get ownerTripsThisMonth => 'Trips this month';

  @override
  String get ownerMyCarsTitle => 'My Cars';

  @override
  String get ownerMyCarsSubtitle => 'Cars you\'re renting out';

  @override
  String get ownerAddCar => 'Add a car';

  @override
  String get ownerNoCars => 'You haven\'t listed any cars yet';

  @override
  String ownerPricePerHour(String price) {
    return '$priceđ/hour';
  }

  @override
  String get ownerStatusReady => 'Available';

  @override
  String get ownerStatusHidden => 'Hidden';

  @override
  String get ownerDeleteTitle => 'Delete car?';

  @override
  String ownerDeleteConfirm(String title) {
    return 'Are you sure you want to remove \"$title\"?';
  }

  @override
  String get ownerDeleteSuccess => 'Vehicle deleted';

  @override
  String get commonNo => 'No';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get bookingStatusPendingPayment => 'Pending payment';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusInProgress => 'Renting';

  @override
  String get bookingStatusCompleted => 'Completed';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get tripsTitle => 'My trips';

  @override
  String get tripsSubtitle => 'Manage your bookings';

  @override
  String get tripsEmpty => 'You don\'t have any trips yet.';

  @override
  String tripsOrderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String get tripsCancelling => 'Cancelling...';

  @override
  String get tripsCancel => 'Cancel booking';

  @override
  String get tripsCancelTitle => 'Cancel this booking?';

  @override
  String get tripsCancelConfirm =>
      'Are you sure you want to cancel this booking?';

  @override
  String get bookingPickDatesTitle => 'Select rental dates';

  @override
  String get bookingPickDatesSubtitle => 'Choose the start and end times';

  @override
  String get bookingRentalPeriod => 'Rental period';

  @override
  String get bookingPickupDateLabel => 'Pick-up date';

  @override
  String get bookingReturnDateLabel => 'Return date';

  @override
  String get bookingChangeDate => 'Change dates';

  @override
  String bookingDays(int count) {
    return '$count days';
  }

  @override
  String get bookingDelivery => 'Door-to-door delivery';

  @override
  String get bookingDeliveryAddressHint => 'Enter the delivery address...';

  @override
  String get bookingEstimatedCost => 'Estimated cost';

  @override
  String bookingRentalLine(String price, int days) {
    return '${price}K × $days days';
  }

  @override
  String get bookingDeliveryFeeLabel => 'Delivery fee';

  @override
  String get bookingInsuranceLabel => 'Insurance (5%)';

  @override
  String get bookingTotal => 'Total';

  @override
  String get bookingConfirmTitle => 'Confirm booking';

  @override
  String get bookingConfirmSubtitle => 'Review the details before booking';

  @override
  String get bookingFailed => 'Booking failed';

  @override
  String get bookingConfirmAndPay => 'Confirm & Pay';

  @override
  String get bookingTermsNote =>
      'By continuing, you agree to RideVN\'s Terms of Service and Privacy Policy.';

  @override
  String get bookingTripDetails => 'Trip details';

  @override
  String get bookingPickup => 'Pick-up';

  @override
  String get bookingReturn => 'Return';

  @override
  String get bookingDuration => 'Duration';

  @override
  String get bookingDeliveryTo => 'Deliver to';

  @override
  String get bookingDeliveryAddressFallback => 'Delivery address';

  @override
  String bookingRentalCarLine(String price, int days) {
    return 'Car rental (${price}K × $days days)';
  }

  @override
  String get bookingDeliveryShort => 'Delivery';

  @override
  String get bookingServiceFee => 'Service fee (3%)';

  @override
  String get bookingTotalPayment => 'Total payment';

  @override
  String get bookingDepositTitle => 'Deposit & Cancellation';

  @override
  String get bookingDepositBody =>
      '30% deposit on confirmation. Full refund if cancelled at least 24h before pick-up.';

  @override
  String get contractTitle => 'Electronic contract';

  @override
  String get contractSubtitle => 'Read carefully and sign';

  @override
  String get contractHeading => 'Rental contract';

  @override
  String contractCode(String code) {
    return 'Contract no.: $code';
  }

  @override
  String get contractPartiesTitle => 'I. PARTIES INVOLVED';

  @override
  String get contractPartiesBody =>
      '• Party A (Owner): Verified through the RideVN KYC system\n• Party B (Renter): Completed identity verification';

  @override
  String get contractVehicleTitle => 'II. VEHICLE INFORMATION';

  @override
  String get contractVehicleBody =>
      'The vehicle is delivered in the described condition. The renter is responsible for inspecting the vehicle before pick-up and confirming in the app.';

  @override
  String get contractTermsTitle => 'III. TERMS OF USE';

  @override
  String get contractTermsBody =>
      '• Do not use the vehicle for unlawful purposes\n• Do not let others drive without the owner\'s consent\n• Return the vehicle on time, at the agreed location\n• Take good care of the vehicle, no unauthorized repairs';

  @override
  String get contractCompensationTitle => 'IV. DAMAGE COMPENSATION';

  @override
  String get contractCompensationBody =>
      'Any damage outside the insurance coverage will be the responsibility of Party B, compensated according to the valuation of an appointed third party.';

  @override
  String get contractAgree =>
      'I have read carefully and agree to all the terms in this rental contract.';

  @override
  String get contractSign => 'Sign contract';

  @override
  String get activeTripTitle => 'Trip in progress';

  @override
  String get activeTripSubtitle => 'Manage your trip';

  @override
  String get activeTripReturn => 'Return car';

  @override
  String get activeTripEmergency => 'Emergency support';

  @override
  String get activeTripReturnTitle => 'Confirm car return?';

  @override
  String get activeTripReturnBody =>
      'Do you confirm that you\'ve returned the car and ended this trip?';

  @override
  String get activeTripNotYet => 'Not yet';

  @override
  String get activeTripRunning => '🟢 Running';

  @override
  String get activeTripRemaining => 'Remaining';

  @override
  String get activeTripProgress => 'Trip progress';

  @override
  String activeTripDaysProgress(int elapsed, int total) {
    return '$elapsed/$total days';
  }

  @override
  String get activeTripVehicleInfo => 'Vehicle info';

  @override
  String activeTripLicensePlate(String plate) {
    return 'Plate: $plate';
  }

  @override
  String get activeTripCall => 'Call';

  @override
  String get activeTripCallOwner => 'Call owner';

  @override
  String get activeTripMap => 'Map';

  @override
  String get activeTripPhoto => 'Take photo';

  @override
  String get activeTripReport => 'Report issue';

  @override
  String get reportSheetTitle => 'Report a problem';

  @override
  String get reportSheetSubtitle =>
      'Add a photo of the issue (optional), then chat with our support team.';

  @override
  String get reportCamera => 'Camera';

  @override
  String get reportGallery => 'Gallery';

  @override
  String get reportPhotoAttached => 'Photo attached';

  @override
  String get reportRemovePhoto => 'Remove';

  @override
  String get reportContinueToSupport => 'Chat with support';

  @override
  String get emergencySheetTitle => 'Emergency';

  @override
  String get emergencySheetSubtitle =>
      'Tap a number to copy it, then call from your phone.';

  @override
  String get emergencyPolice => 'Police';

  @override
  String get emergencyFire => 'Fire & rescue';

  @override
  String get emergencyAmbulance => 'Ambulance';

  @override
  String emergencyNumberCopied(String label, String number) {
    return '$label number $number copied';
  }

  @override
  String get emergencyTipsTitle => 'Safety tips';

  @override
  String get emergencyTipSafePlace =>
      'Move to a safe place before making a call.';

  @override
  String get emergencyTipShareLocation =>
      'Share your live location with someone you trust.';

  @override
  String get emergencyTipNoteDetails =>
      'Note the vehicle plate, your location, and what happened.';

  @override
  String get commonYes => 'Yes';

  @override
  String get vehicleTransmissionNone => 'Not applicable';

  @override
  String get ownerCalendarTitle => 'Vehicle calendar';

  @override
  String get ownerCalendarSubtitle => 'Manage your rental schedule';

  @override
  String get ownerPendingApproval => 'Pending';

  @override
  String get ownerToday => 'Today';

  @override
  String get ownerNeedsResponse => 'Needs response';

  @override
  String get ownerNoPendingRequests => 'No requests pending';

  @override
  String get ownerReject => 'Reject';

  @override
  String get ownerApprove => 'Approve';

  @override
  String get ownerRequestDetailTitle => 'Request details';

  @override
  String get ownerRequestDetailSubtitle =>
      'Review and handle the rental request';

  @override
  String get ownerNoRequestData => 'No request data';

  @override
  String get ownerRequestApproved => 'Request approved';

  @override
  String get ownerRequestRejected => 'Request rejected';

  @override
  String ownerSentOn(String date) {
    return 'Sent $date';
  }

  @override
  String ownerHours(int count) {
    return '$count hours';
  }

  @override
  String get ownerTotalRental => 'Total rental';

  @override
  String get ownerPlatformFee => 'Platform fee (10%)';

  @override
  String get ownerYouReceive => 'You receive';

  @override
  String get ownerProcessing => 'Processing…';

  @override
  String get ownerApproveRequest => 'Approve request';

  @override
  String get ownerRequestHandled => 'This request has already been handled.';

  @override
  String get ownerStatusPendingConfirm => '🟡 Awaiting confirmation';

  @override
  String get ownerStatusConfirmed => '✅ Confirmed';

  @override
  String get ownerStatusInProgress => '🚗 Renting';

  @override
  String get ownerStatusCompleted => '✔ Completed';

  @override
  String get ownerStatusCancelled => '✖ Cancelled';

  @override
  String get ownerStatusUnknown => 'Unknown';

  @override
  String get ownerRevenueTitle => 'Revenue report';

  @override
  String get ownerRevenueSubtitle => 'Track your income';

  @override
  String get ownerIncomeThisMonth => 'Income this month';

  @override
  String ownerPaidTrips(int count) {
    return '$count paid trips';
  }

  @override
  String get ownerRevenueChart => 'Revenue chart';

  @override
  String get ownerNoRevenue => 'No revenue in this period yet';

  @override
  String get ownerRecentTransactions => 'Recent transactions';

  @override
  String get ownerNoTransactions => 'No transactions yet';

  @override
  String get ownerVehicleNameRequired => 'Please enter the vehicle name';

  @override
  String get ownerVehiclePriceInvalid => 'Rental price must be greater than 0';

  @override
  String get ownerVehicleCoordsInvalid => 'Invalid coordinates';

  @override
  String get ownerVehicleUpdateSuccess => 'Vehicle updated successfully';

  @override
  String get ownerVehicleCreateSuccess => 'Vehicle published successfully';

  @override
  String get ownerVehicleEditTitle => 'Edit vehicle';

  @override
  String get ownerVehicleAddTitle => 'List a new vehicle';

  @override
  String get ownerVehicleEditSubtitle => 'Update your vehicle\'s information';

  @override
  String get ownerVehicleAddSubtitle =>
      'Fill in the details to list your vehicle';

  @override
  String get ownerVehicleSaveChanges => 'Save changes';

  @override
  String get ownerVehiclePublish => 'Publish';

  @override
  String get ownerVehiclePhotos => 'Vehicle photos';

  @override
  String get ownerVehiclePhotosHint =>
      'Up to 10 photos · The first is the cover';

  @override
  String get ownerVehicleAddPhoto => 'Add photo';

  @override
  String get ownerVehicleBasicInfo => 'Basic information';

  @override
  String get ownerVehicleName => 'Vehicle name';

  @override
  String get ownerVehicleNameHint => 'e.g. Toyota Camry 2024';

  @override
  String get ownerVehiclePricePerHour => 'Price/hour (VND)';

  @override
  String get ownerVehiclePriceHint => 'e.g. 50000';

  @override
  String get ownerVehicleType => 'Vehicle type';

  @override
  String get ownerVehicleLocation => 'Vehicle location';

  @override
  String get ownerVehicleLat => 'Latitude (lat)';

  @override
  String get ownerVehicleLatHint => 'e.g. 21.0278';

  @override
  String get ownerVehicleLng => 'Longitude (lng)';

  @override
  String get ownerVehicleLngHint => 'e.g. 105.8342';

  @override
  String get ownerVehicleMapSoon =>
      'Picking a location on the map is coming soon.';

  @override
  String get ownerVehicleSpecs => 'Specifications';

  @override
  String get ownerVehicleSpecsHint =>
      'Can be left empty if not applicable (e.g. motorbike, bicycle).';

  @override
  String get ownerVehicleSeats => 'Seats';

  @override
  String get ownerVehicleSeatsHint => 'e.g. 5';

  @override
  String get ownerVehicleDoors => 'Doors';

  @override
  String get ownerVehicleDoorsHint => 'e.g. 4';

  @override
  String get ownerVehicleTransmission => 'Transmission';

  @override
  String get ownerVehicleCity => 'City';

  @override
  String get ownerVehicleCityHint => 'e.g. HCMC';

  @override
  String get ownerVehicleDescription => 'Vehicle description';

  @override
  String get ownerVehicleDescriptionHint =>
      'Describe the condition and standout features...';

  @override
  String get ownerVehicleOptions => 'Options';

  @override
  String get ownerVehicleEv => 'Electric (EV)';

  @override
  String get ownerVehicleEvSubtitle => 'Show the EV badge on the listing';

  @override
  String get ownerVehicleDeliverySubtitle =>
      'Allow delivery to the customer\'s address';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutConfirm =>
      'Are you sure you want to log out of this account?';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionOther => 'Other';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Receive push notifications';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get themePickerTitle => 'Display mode';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsAboutSubtitle(String version) {
    return 'RideVN · Version $version';
  }

  @override
  String settingsVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get settingsTermsPolicies => 'Terms & policies';

  @override
  String get termsScreenTitle => 'Terms & Policies';

  @override
  String get termsUpdatedLabel => 'Last updated June 2026';

  @override
  String get termsIntroHeading => '1. Acceptance of terms';

  @override
  String get termsIntroBody =>
      'By creating an account or using RideVN, you agree to these Terms & Policies. If you do not agree, please stop using the app. We may update these terms from time to time and will note the date of the latest revision above.';

  @override
  String get termsAccountHeading => '2. Your account';

  @override
  String get termsAccountBody =>
      'You are responsible for keeping your login credentials secure and for all activity under your account. You must provide accurate information and complete identity verification (KYC) before renting or listing a vehicle. You may hold both renter and owner roles on one account.';

  @override
  String get termsBookingHeading => '3. Bookings & payments';

  @override
  String get termsBookingBody =>
      'A booking is a contract between the renter and the vehicle owner; RideVN facilitates the transaction. Prices, deposits and any surge adjustments are shown before you confirm. Payments are processed through our supported gateways. Cancellation and refund eligibility depend on the timing of the cancellation and the owner\'s policy shown at checkout.';

  @override
  String get termsConductHeading => '4. Vehicle use & conduct';

  @override
  String get termsConductBody =>
      'Renters must hold a valid licence, drive lawfully, and return the vehicle on time, in the agreed condition, and at the agreed location. Owners must keep their vehicles roadworthy, insured, and accurately described. Prohibited use includes illegal activity, subletting, and removing tracking or safety equipment.';

  @override
  String get termsPrivacyHeading => '5. Privacy & your data';

  @override
  String get termsPrivacyBody =>
      'We collect the data needed to operate the service — account details, KYC documents, location used for nearby search, bookings and payments. KYC documents are stored privately and are never shared publicly. We do not sell your personal data. You can request access to or deletion of your account data from Settings.';

  @override
  String get termsContactHeading => '6. Contact us';

  @override
  String get termsContactBody =>
      'Questions about these terms or your data? Reach our support team from the in-app chat, or email support@ridevn.app.';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordNew => 'New password';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordSubmit => 'Update password';

  @override
  String get changePasswordSuccess => 'Password updated';

  @override
  String get changePasswordFillAll => 'Please fill in all fields';

  @override
  String get changePasswordTooShort =>
      'New password must be at least 8 characters';

  @override
  String get changePasswordMismatch => 'New passwords do not match';

  @override
  String get changePasswordSameAsCurrent =>
      'New password must be different from the current one';

  @override
  String get deleteAccountWarning =>
      'This permanently deletes your account and all related data — bookings, vehicles, reviews and messages. This cannot be undone.';

  @override
  String get deleteAccountConfirmCheckbox =>
      'I understand this action is permanent.';

  @override
  String get deleteAccountConfirmButton => 'Delete my account';

  @override
  String get profileEditSubtitle => 'Update your personal information';

  @override
  String get profileUpdateSuccess => 'Profile updated';

  @override
  String get profileUpdateFailed => 'Update failed';

  @override
  String get profileChangeAvatar => 'Change avatar';

  @override
  String get profilePersonalInfo => 'Personal information';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhoneReadonly => 'Phone number can\'t be changed';

  @override
  String get profileBio => 'About you';

  @override
  String get profileBioHint => 'Share a little about yourself...';

  @override
  String commonComingSoonSnack(String feature) {
    return '$feature coming soon';
  }

  @override
  String get navFindCar => 'Find a car';

  @override
  String get navVehicles => 'Cars';

  @override
  String get navTrips => 'Trips';

  @override
  String get navMap => 'Map';

  @override
  String get navMe => 'Me';

  @override
  String get shellAccountTitle => 'Account';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifEmpty => 'No notifications yet';

  @override
  String get loyaltySubtitle => 'Earn points for every trip';

  @override
  String get loyaltyPointsUnit => 'reward points';

  @override
  String get loyaltyTier => 'Tier';

  @override
  String loyaltyPointsToNext(int points, String tier) {
    return '$points more points to $tier';
  }

  @override
  String get loyaltyHistory => 'Points history';

  @override
  String get loyaltyNoHistory => 'No points history yet';

  @override
  String loyaltyPointsShort(int points) {
    return '$points pts';
  }

  @override
  String get communityTitle => 'Community';

  @override
  String get communityLatestStories => 'Latest stories';

  @override
  String get communityEmpty => 'No stories yet';

  @override
  String get communityShareTrip => 'Share a trip';

  @override
  String get communityComposerHint => 'Tell us about your trip...';

  @override
  String get communityPost => 'Post';

  @override
  String get communityBannerPrompt => 'Share your trip...';

  @override
  String get chatTitle => 'Messages';

  @override
  String get chatEmpty => 'No conversations yet';

  @override
  String get chatStartConversation => 'Start a conversation';

  @override
  String get chatNoMessages => 'No messages yet';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentSubtitle => 'Choose a payment method';

  @override
  String paymentPayAmount(String amount) {
    return 'Pay $amount VNĐ';
  }

  @override
  String get paymentAmount => 'Payment amount';

  @override
  String get paymentSslBadge => '🔒  Secure SSL payment';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentMethodVnpayDesc => 'VNPay wallet & domestic ATM';

  @override
  String get paymentMethodMomoDesc => 'MoMo e-wallet';

  @override
  String get paymentMethodZalopayDesc => 'ZaloPay e-wallet';

  @override
  String get paymentMethodCard => 'International card';

  @override
  String get paymentSslEncryption => 'Transactions encrypted with 256-bit SSL';

  @override
  String get paymentVnpayTitle => 'VNPay payment';

  @override
  String get paymentResultSuccessTitle => 'Payment successful!';

  @override
  String get paymentResultFailTitle => 'Payment failed';

  @override
  String get paymentResultSuccessBody =>
      'Your trip has been confirmed.\nEnjoy your trip!';

  @override
  String get paymentResultFailBody =>
      'The transaction was unsuccessful.\nPlease try again or choose another method.';

  @override
  String get paymentViewTrip => 'View trip';

  @override
  String get paymentBackHome => 'Back home';

  @override
  String get paymentAmountLabel => 'Amount';

  @override
  String get paymentTxnId => 'Transaction ID';

  @override
  String get paymentTime => 'Time';

  @override
  String get paymentStatusLabel => 'Status';

  @override
  String get paymentStatusSuccess => '✅ Success';

  @override
  String get reviewTitle => 'Rate your trip';

  @override
  String get reviewSubtitle => 'Share your experience';

  @override
  String get reviewVehicleQuality => 'Vehicle quality';

  @override
  String get reviewTagClean => 'Clean car';

  @override
  String get reviewTagOnTime => 'On time';

  @override
  String get reviewTagFriendlyOwner => 'Friendly owner';

  @override
  String get reviewTagAsDescribed => 'As described';

  @override
  String get reviewTagDelivery => 'Door-to-door delivery';

  @override
  String get reviewTagFairPrice => 'Fair price';

  @override
  String get reviewRatingBad => 'Bad';

  @override
  String get reviewRatingPoor => 'Poor';

  @override
  String get reviewRatingOk => 'Okay';

  @override
  String get reviewRatingGood => 'Good';

  @override
  String get reviewRatingExcellent => 'Excellent';

  @override
  String get reviewCompleted => '✅ Completed';

  @override
  String get reviewHighlights => 'Highlights';

  @override
  String get reviewCommentLabel => 'Additional comments (optional)';

  @override
  String get reviewCommentHint => 'Share your experience...';

  @override
  String get reviewSubmit => 'Submit review';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String reviewsAboutUser(String name) {
    return 'Reviews about $name';
  }

  @override
  String get reviewsAllReceived => 'All received reviews';

  @override
  String get reviewsEmpty => 'No reviews yet';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String get reviewsLoadError => 'Couldn\'t load reviews. Try again later.';

  @override
  String reviewsViewAll(int count) {
    return 'View all $count reviews';
  }

  @override
  String get kycTitle => 'Identity verification';

  @override
  String get kycSubtitle => 'Complete KYC to rent and list vehicles';

  @override
  String get kycStepCccd => 'National ID card';

  @override
  String get kycStepLicense => 'Driver\'s license';

  @override
  String get kycStepSelfie => 'Portrait photo (selfie)';

  @override
  String get kycSelfieHint => 'Face the camera, with good lighting';

  @override
  String get kycSubmit => 'Submit verification';

  @override
  String get kycInfoBanner =>
      'Your information is encrypted and secure. Used only for identity verification.';

  @override
  String get kycUploaded => 'Uploaded';

  @override
  String get kycUploading => 'Uploading...';

  @override
  String get kycTapToUpload => 'Tap to upload a photo';

  @override
  String get kycStatusTitle => 'KYC status';

  @override
  String get kycStatusSubtitle => 'Your identity verification';

  @override
  String get kycStatusUnverifiedTitle => 'No documents submitted';

  @override
  String get kycStatusUnverifiedSubtitle =>
      'You haven\'t submitted verification documents.\nSubmit your ID, license and selfie to begin.';

  @override
  String get kycStatusPendingTitle => 'Under review';

  @override
  String get kycStatusPendingSubtitle =>
      'Your documents are being reviewed.\nUsually takes 1–2 business days.';

  @override
  String get kycStatusApprovedTitle => 'Verified';

  @override
  String get kycStatusApprovedSubtitle =>
      'Your account is verified.\nYou can rent a car now.';

  @override
  String get kycStatusRejectedTitle => 'Verification failed';

  @override
  String get kycStatusRejectedSubtitle =>
      'Your documents were rejected. Please\nresubmit with clearer photos.';

  @override
  String get kycTimelineTitle => 'Review progress';

  @override
  String get kycStepSubmit => 'Submit documents';

  @override
  String get kycStepReview => 'Under review';

  @override
  String get kycStepComplete => 'Verification complete';

  @override
  String get kycStepRejected => 'Rejected';

  @override
  String get kycNotSubmitted => 'Not submitted';

  @override
  String get kycProcessing => 'Processing...';

  @override
  String get kycRejectReason => 'Rejection reason';

  @override
  String get kycSubmitDocs => 'Submit KYC documents';

  @override
  String get kycFindCarNow => 'Find a car now';

  @override
  String get kycResubmit => 'Resubmit documents';

  @override
  String get kycContactSupport => 'Contact support';
}
