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
  String get kycPending => '⏳ KYC Under review';

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
}
