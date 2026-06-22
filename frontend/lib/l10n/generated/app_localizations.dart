import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Application name shown in headers
  ///
  /// In en, this message translates to:
  /// **'RideVN'**
  String get appTitle;

  /// Settings row label for the language picker
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Title of the language selection bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get languagePickerTitle;

  /// Display name for the Vietnamese language option (shown in its own language)
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// Display name for the English language option (shown in its own language)
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Label for phone number input fields
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// Label for password input fields
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// Login screen heading and submit button
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number and password to continue'**
  String get authLoginSubtitle;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// No description provided for @authRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get authRegisterNow;

  /// Register screen app bar title and submit button
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get authRegisterSectionAccount;

  /// No description provided for @authEmailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get authEmailOptionalLabel;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordHintMin.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordHintMin;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordMismatch;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authAgreeTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms of use'**
  String get authAgreeTermsRequired;

  /// No description provided for @authTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get authTermsPrefix;

  /// No description provided for @authTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get authTermsOfUse;

  /// No description provided for @authTermsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authTermsAnd;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **' of RideVN'**
  String get authTermsSuffix;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get authOtpTitle;

  /// No description provided for @authOtpSentToPrefix.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to '**
  String get authOtpSentToPrefix;

  /// No description provided for @authOtpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authOtpConfirm;

  /// No description provided for @authOtpResendInPrefix.
  ///
  /// In en, this message translates to:
  /// **'Resend in '**
  String get authOtpResendInPrefix;

  /// Resend countdown remaining seconds
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String authOtpSeconds(int seconds);

  /// No description provided for @authOtpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP code'**
  String get authOtpResend;

  /// No description provided for @authOtpDemoHint.
  ///
  /// In en, this message translates to:
  /// **'Use code 123456 to test in the demo environment.'**
  String get authOtpDemoHint;

  /// No description provided for @authOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code. Please try again.'**
  String get authOtpInvalid;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get commonUser;

  /// No description provided for @roleRenter.
  ///
  /// In en, this message translates to:
  /// **'Renter'**
  String get roleRenter;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @kycVerified.
  ///
  /// In en, this message translates to:
  /// **'✓ KYC Verified'**
  String get kycVerified;

  /// No description provided for @kycPending.
  ///
  /// In en, this message translates to:
  /// **'⏳ KYC Under review'**
  String get kycPending;

  /// No description provided for @kycRejected.
  ///
  /// In en, this message translates to:
  /// **'✕ KYC Rejected'**
  String get kycRejected;

  /// No description provided for @kycUnverified.
  ///
  /// In en, this message translates to:
  /// **'! KYC Not verified'**
  String get kycUnverified;

  /// No description provided for @kycUnverifiedShort.
  ///
  /// In en, this message translates to:
  /// **'KYC not verified'**
  String get kycUnverifiedShort;

  /// No description provided for @vehicleTypeCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleTypeCar;

  /// No description provided for @vehicleTypeMotorbike.
  ///
  /// In en, this message translates to:
  /// **'Motorbike'**
  String get vehicleTypeMotorbike;

  /// No description provided for @vehicleTypeBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get vehicleTypeBicycle;

  /// No description provided for @vehicleTransmissionAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get vehicleTransmissionAutomatic;

  /// No description provided for @vehicleTransmissionManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get vehicleTransmissionManual;

  /// No description provided for @vehicleElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get vehicleElectric;

  /// No description provided for @vehicleFuelGas.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get vehicleFuelGas;

  /// No description provided for @vehiclePerDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get vehiclePerDay;

  /// No description provided for @vehicleAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get vehicleAvailable;

  /// No description provided for @vehicleInStock.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get vehicleInStock;

  /// No description provided for @vehicleRented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get vehicleRented;

  /// No description provided for @vehicleDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get vehicleDelivery;

  /// No description provided for @vehicleFindCars.
  ///
  /// In en, this message translates to:
  /// **'Find a car'**
  String get vehicleFindCars;

  /// No description provided for @vehicleFavoriteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update favorites, please try again later'**
  String get vehicleFavoriteError;

  /// Seat count spec on a vehicle
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String vehicleSeats(int count);

  /// Door count spec on a vehicle
  ///
  /// In en, this message translates to:
  /// **'{count} doors'**
  String vehicleDoors(int count);

  /// No description provided for @vehicleNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Location not updated'**
  String get vehicleNoLocation;

  /// No description provided for @vehicleNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get vehicleNotUpdated;

  /// No description provided for @vehicleOwnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get vehicleOwnerFallback;

  /// No description provided for @vehicleMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get vehicleMessage;

  /// No description provided for @vehicleShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get vehicleShare;

  /// No description provided for @vehicleBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get vehicleBookNow;

  /// No description provided for @vehicleOwnerMetaSample.
  ///
  /// In en, this message translates to:
  /// **' · 36 trips · Fast response'**
  String get vehicleOwnerMetaSample;

  /// No description provided for @vehicleBadgeInstant.
  ///
  /// In en, this message translates to:
  /// **'⚡ Instant book'**
  String get vehicleBadgeInstant;

  /// No description provided for @vehicleBadgeElectric.
  ///
  /// In en, this message translates to:
  /// **'🔋 Electric'**
  String get vehicleBadgeElectric;

  /// No description provided for @vehicleBadgeWeekendDiscount.
  ///
  /// In en, this message translates to:
  /// **'🏷 −15% weekends'**
  String get vehicleBadgeWeekendDiscount;

  /// No description provided for @vehicleTripRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip rules'**
  String get vehicleTripRulesTitle;

  /// No description provided for @vehicleRuleNoSmoking.
  ///
  /// In en, this message translates to:
  /// **'No smoking in the car'**
  String get vehicleRuleNoSmoking;

  /// No description provided for @vehicleRuleNoBulkyGoods.
  ///
  /// In en, this message translates to:
  /// **'No bulky cargo'**
  String get vehicleRuleNoBulkyGoods;

  /// No description provided for @vehicleRuleReturnOnTime.
  ///
  /// In en, this message translates to:
  /// **'Return on time, at the right place'**
  String get vehicleRuleReturnOnTime;

  /// No description provided for @vehicleRuleCleanBeforeReturn.
  ///
  /// In en, this message translates to:
  /// **'Clean the car before returning'**
  String get vehicleRuleCleanBeforeReturn;

  /// No description provided for @vehiclePickupLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick-up location'**
  String get vehiclePickupLocationTitle;

  /// No description provided for @vehicleFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get vehicleFilterAll;

  /// No description provided for @vehicleFilterSaved.
  ///
  /// In en, this message translates to:
  /// **'❤️ Saved'**
  String get vehicleFilterSaved;

  /// No description provided for @vehicleFilterInstant.
  ///
  /// In en, this message translates to:
  /// **'⚡ Instant book'**
  String get vehicleFilterInstant;

  /// No description provided for @vehicleFilterAuto.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Automatic'**
  String get vehicleFilterAuto;

  /// No description provided for @vehicleFilterElectric.
  ///
  /// In en, this message translates to:
  /// **'🔋 Electric'**
  String get vehicleFilterElectric;

  /// No description provided for @vehicleFilter5Seats.
  ///
  /// In en, this message translates to:
  /// **'5 seats'**
  String get vehicleFilter5Seats;

  /// No description provided for @vehicleFilter7Seats.
  ///
  /// In en, this message translates to:
  /// **'7+ seats'**
  String get vehicleFilter7Seats;

  /// No description provided for @vehicleSortPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get vehicleSortPopular;

  /// No description provided for @vehicleSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get vehicleSortPriceLow;

  /// No description provided for @vehicleSortRatingHigh.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get vehicleSortRatingHigh;

  /// No description provided for @vehicleSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get vehicleSortNearest;

  /// Number of vehicles matching the filters
  ///
  /// In en, this message translates to:
  /// **'{count} matching cars'**
  String vehicleCountMatched(int count);

  /// Number of saved vehicles
  ///
  /// In en, this message translates to:
  /// **'{count} saved cars'**
  String vehicleCountSaved(int count);

  /// No description provided for @vehicleListView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get vehicleListView;

  /// No description provided for @vehicleMapView.
  ///
  /// In en, this message translates to:
  /// **'View map'**
  String get vehicleMapView;

  /// No description provided for @vehicleLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get vehicleLocationLabel;

  /// No description provided for @vehicleLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'District 1, HCMC'**
  String get vehicleLocationPlaceholder;

  /// No description provided for @vehicleTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get vehicleTimeLabel;

  /// No description provided for @vehicleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching cars'**
  String get vehicleEmptyTitle;

  /// No description provided for @vehicleEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filters or another search'**
  String get vehicleEmptySubtitle;

  /// No description provided for @vehicleEmptySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved cars yet'**
  String get vehicleEmptySavedTitle;

  /// No description provided for @vehicleEmptySavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on a car to save it for later'**
  String get vehicleEmptySavedSubtitle;

  /// No description provided for @vehicleListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the car list'**
  String get vehicleListErrorTitle;

  /// No description provided for @vehicleFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get vehicleFilterTitle;

  /// No description provided for @vehicleFilterMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price / day'**
  String get vehicleFilterMaxPrice;

  /// No description provided for @vehicleFilterMinRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get vehicleFilterMinRating;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello there'**
  String get homeGreeting;

  /// No description provided for @homeGreetingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where are you going today?'**
  String get homeGreetingQuestion;

  /// No description provided for @homeLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'PICK-UP POINT'**
  String get homeLocationLabel;

  /// No description provided for @homePickupDateLabel.
  ///
  /// In en, this message translates to:
  /// **'PICK-UP'**
  String get homePickupDateLabel;

  /// No description provided for @homeReturnDateLabel.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get homeReturnDateLabel;

  /// No description provided for @homeSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get homeSelectDate;

  /// No description provided for @homeCityPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select pick-up location'**
  String get homeCityPickerTitle;

  /// No description provided for @homeExploreByCity.
  ///
  /// In en, this message translates to:
  /// **'Explore by city'**
  String get homeExploreByCity;

  /// No description provided for @homeFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured cars near you'**
  String get homeFeaturedTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeFeaturedError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load featured cars'**
  String get homeFeaturedError;

  /// No description provided for @homeTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Every trip is insured'**
  String get homeTrustTitle;

  /// No description provided for @homeTrustSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 200 million VND coverage for any damage.'**
  String get homeTrustSubtitle;

  /// No description provided for @dashboardMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get dashboardMyProfile;

  /// No description provided for @dashboardRenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account & loyalty points'**
  String get dashboardRenterSubtitle;

  /// No description provided for @dashboardActiveRenting.
  ///
  /// In en, this message translates to:
  /// **'Renting'**
  String get dashboardActiveRenting;

  /// No description provided for @dashboardUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get dashboardUpcoming;

  /// No description provided for @dashboardTotalTrips.
  ///
  /// In en, this message translates to:
  /// **'Total trips'**
  String get dashboardTotalTrips;

  /// No description provided for @dashboardLoyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty points'**
  String get dashboardLoyaltyPoints;

  /// No description provided for @unitVehicles.
  ///
  /// In en, this message translates to:
  /// **'cars'**
  String get unitVehicles;

  /// No description provided for @unitTrips.
  ///
  /// In en, this message translates to:
  /// **'trips'**
  String get unitTrips;

  /// No description provided for @ownerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner home'**
  String get ownerDashboardTitle;

  /// No description provided for @ownerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your rental cars and trips'**
  String get ownerDashboardSubtitle;

  /// No description provided for @ownerRevenueMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get ownerRevenueMonth;

  /// No description provided for @ownerYourCars.
  ///
  /// In en, this message translates to:
  /// **'Your cars'**
  String get ownerYourCars;

  /// No description provided for @ownerTripsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Trips this month'**
  String get ownerTripsThisMonth;

  /// No description provided for @ownerMyCarsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get ownerMyCarsTitle;

  /// No description provided for @ownerMyCarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cars you\'re renting out'**
  String get ownerMyCarsSubtitle;

  /// No description provided for @ownerAddCar.
  ///
  /// In en, this message translates to:
  /// **'Add a car'**
  String get ownerAddCar;

  /// No description provided for @ownerNoCars.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t listed any cars yet'**
  String get ownerNoCars;

  /// Owner's car price per hour (price already formatted)
  ///
  /// In en, this message translates to:
  /// **'{price}đ/hour'**
  String ownerPricePerHour(String price);

  /// No description provided for @ownerStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get ownerStatusReady;

  /// No description provided for @ownerStatusHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get ownerStatusHidden;

  /// No description provided for @ownerDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete car?'**
  String get ownerDeleteTitle;

  /// Delete vehicle confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{title}\"?'**
  String ownerDeleteConfirm(String title);

  /// No description provided for @ownerDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle deleted'**
  String get ownerDeleteSuccess;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @bookingStatusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get bookingStatusPendingPayment;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Renting'**
  String get bookingStatusInProgress;

  /// No description provided for @bookingStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingStatusCompleted;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// No description provided for @tripsTitle.
  ///
  /// In en, this message translates to:
  /// **'My trips'**
  String get tripsTitle;

  /// No description provided for @tripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your bookings'**
  String get tripsSubtitle;

  /// No description provided for @tripsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any trips yet.'**
  String get tripsEmpty;

  /// Short booking order number shown on a trip card
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String tripsOrderNumber(String id);

  /// No description provided for @tripsCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling...'**
  String get tripsCancelling;

  /// No description provided for @tripsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get tripsCancel;

  /// No description provided for @tripsCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get tripsCancelTitle;

  /// No description provided for @tripsCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get tripsCancelConfirm;

  /// No description provided for @bookingPickDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select rental dates'**
  String get bookingPickDatesTitle;

  /// No description provided for @bookingPickDatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the start and end times'**
  String get bookingPickDatesSubtitle;

  /// No description provided for @bookingRentalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rental period'**
  String get bookingRentalPeriod;

  /// No description provided for @bookingPickupDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick-up date'**
  String get bookingPickupDateLabel;

  /// No description provided for @bookingReturnDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Return date'**
  String get bookingReturnDateLabel;

  /// No description provided for @bookingChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change dates'**
  String get bookingChangeDate;

  /// Number of rental days
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String bookingDays(int count);

  /// No description provided for @bookingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Door-to-door delivery'**
  String get bookingDelivery;

  /// No description provided for @bookingDeliveryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the delivery address...'**
  String get bookingDeliveryAddressHint;

  /// No description provided for @bookingEstimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost'**
  String get bookingEstimatedCost;

  /// Rental cost line: price per day times number of days (price already formatted)
  ///
  /// In en, this message translates to:
  /// **'{price}K × {days} days'**
  String bookingRentalLine(String price, int days);

  /// No description provided for @bookingDeliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get bookingDeliveryFeeLabel;

  /// No description provided for @bookingInsuranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurance (5%)'**
  String get bookingInsuranceLabel;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bookingTotal;

  /// No description provided for @bookingConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get bookingConfirmTitle;

  /// No description provided for @bookingConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the details before booking'**
  String get bookingConfirmSubtitle;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get bookingFailed;

  /// No description provided for @bookingConfirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get bookingConfirmAndPay;

  /// No description provided for @bookingTermsNote.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to RideVN\'s Terms of Service and Privacy Policy.'**
  String get bookingTermsNote;

  /// No description provided for @bookingTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip details'**
  String get bookingTripDetails;

  /// No description provided for @bookingPickup.
  ///
  /// In en, this message translates to:
  /// **'Pick-up'**
  String get bookingPickup;

  /// No description provided for @bookingReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get bookingReturn;

  /// No description provided for @bookingDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get bookingDuration;

  /// No description provided for @bookingDeliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get bookingDeliveryTo;

  /// No description provided for @bookingDeliveryAddressFallback.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get bookingDeliveryAddressFallback;

  /// Car rental summary line with price per day and number of days (price already formatted)
  ///
  /// In en, this message translates to:
  /// **'Car rental ({price}K × {days} days)'**
  String bookingRentalCarLine(String price, int days);

  /// No description provided for @bookingDeliveryShort.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get bookingDeliveryShort;

  /// No description provided for @bookingServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee (3%)'**
  String get bookingServiceFee;

  /// No description provided for @bookingTotalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total payment'**
  String get bookingTotalPayment;

  /// No description provided for @bookingDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit & Cancellation'**
  String get bookingDepositTitle;

  /// No description provided for @bookingDepositBody.
  ///
  /// In en, this message translates to:
  /// **'30% deposit on confirmation. Full refund if cancelled at least 24h before pick-up.'**
  String get bookingDepositBody;

  /// No description provided for @contractTitle.
  ///
  /// In en, this message translates to:
  /// **'Electronic contract'**
  String get contractTitle;

  /// No description provided for @contractSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read carefully and sign'**
  String get contractSubtitle;

  /// No description provided for @contractHeading.
  ///
  /// In en, this message translates to:
  /// **'Rental contract'**
  String get contractHeading;

  /// Contract reference code shown on the contract header
  ///
  /// In en, this message translates to:
  /// **'Contract no.: {code}'**
  String contractCode(String code);

  /// No description provided for @contractPartiesTitle.
  ///
  /// In en, this message translates to:
  /// **'I. PARTIES INVOLVED'**
  String get contractPartiesTitle;

  /// No description provided for @contractPartiesBody.
  ///
  /// In en, this message translates to:
  /// **'• Party A (Owner): Verified through the RideVN KYC system\n• Party B (Renter): Completed identity verification'**
  String get contractPartiesBody;

  /// No description provided for @contractVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'II. VEHICLE INFORMATION'**
  String get contractVehicleTitle;

  /// No description provided for @contractVehicleBody.
  ///
  /// In en, this message translates to:
  /// **'The vehicle is delivered in the described condition. The renter is responsible for inspecting the vehicle before pick-up and confirming in the app.'**
  String get contractVehicleBody;

  /// No description provided for @contractTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'III. TERMS OF USE'**
  String get contractTermsTitle;

  /// No description provided for @contractTermsBody.
  ///
  /// In en, this message translates to:
  /// **'• Do not use the vehicle for unlawful purposes\n• Do not let others drive without the owner\'s consent\n• Return the vehicle on time, at the agreed location\n• Take good care of the vehicle, no unauthorized repairs'**
  String get contractTermsBody;

  /// No description provided for @contractCompensationTitle.
  ///
  /// In en, this message translates to:
  /// **'IV. DAMAGE COMPENSATION'**
  String get contractCompensationTitle;

  /// No description provided for @contractCompensationBody.
  ///
  /// In en, this message translates to:
  /// **'Any damage outside the insurance coverage will be the responsibility of Party B, compensated according to the valuation of an appointed third party.'**
  String get contractCompensationBody;

  /// No description provided for @contractAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read carefully and agree to all the terms in this rental contract.'**
  String get contractAgree;

  /// No description provided for @contractSign.
  ///
  /// In en, this message translates to:
  /// **'Sign contract'**
  String get contractSign;

  /// No description provided for @activeTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get activeTripTitle;

  /// No description provided for @activeTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your trip'**
  String get activeTripSubtitle;

  /// No description provided for @activeTripReturn.
  ///
  /// In en, this message translates to:
  /// **'Return car'**
  String get activeTripReturn;

  /// No description provided for @activeTripEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency support'**
  String get activeTripEmergency;

  /// No description provided for @activeTripReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm car return?'**
  String get activeTripReturnTitle;

  /// No description provided for @activeTripReturnBody.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm that you\'ve returned the car and ended this trip?'**
  String get activeTripReturnBody;

  /// No description provided for @activeTripNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get activeTripNotYet;

  /// No description provided for @activeTripRunning.
  ///
  /// In en, this message translates to:
  /// **'🟢 Running'**
  String get activeTripRunning;

  /// No description provided for @activeTripRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get activeTripRemaining;

  /// No description provided for @activeTripProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip progress'**
  String get activeTripProgress;

  /// Elapsed vs total rental days progress
  ///
  /// In en, this message translates to:
  /// **'{elapsed}/{total} days'**
  String activeTripDaysProgress(int elapsed, int total);

  /// No description provided for @activeTripVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle info'**
  String get activeTripVehicleInfo;

  /// Vehicle license plate label
  ///
  /// In en, this message translates to:
  /// **'Plate: {plate}'**
  String activeTripLicensePlate(String plate);

  /// No description provided for @activeTripCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get activeTripCall;

  /// No description provided for @activeTripCallOwner.
  ///
  /// In en, this message translates to:
  /// **'Call owner'**
  String get activeTripCallOwner;

  /// No description provided for @activeTripMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get activeTripMap;

  /// No description provided for @activeTripPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get activeTripPhoto;

  /// No description provided for @activeTripReport.
  ///
  /// In en, this message translates to:
  /// **'Report issue'**
  String get activeTripReport;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @vehicleTransmissionNone.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get vehicleTransmissionNone;

  /// No description provided for @ownerCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle calendar'**
  String get ownerCalendarTitle;

  /// No description provided for @ownerCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your rental schedule'**
  String get ownerCalendarSubtitle;

  /// No description provided for @ownerPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ownerPendingApproval;

  /// No description provided for @ownerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ownerToday;

  /// No description provided for @ownerNeedsResponse.
  ///
  /// In en, this message translates to:
  /// **'Needs response'**
  String get ownerNeedsResponse;

  /// No description provided for @ownerNoPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests pending'**
  String get ownerNoPendingRequests;

  /// No description provided for @ownerReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ownerReject;

  /// No description provided for @ownerApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get ownerApprove;

  /// No description provided for @ownerRequestDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get ownerRequestDetailTitle;

  /// No description provided for @ownerRequestDetailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and handle the rental request'**
  String get ownerRequestDetailSubtitle;

  /// No description provided for @ownerNoRequestData.
  ///
  /// In en, this message translates to:
  /// **'No request data'**
  String get ownerNoRequestData;

  /// No description provided for @ownerRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get ownerRequestApproved;

  /// No description provided for @ownerRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get ownerRequestRejected;

  /// When the rental request was sent
  ///
  /// In en, this message translates to:
  /// **'Sent {date}'**
  String ownerSentOn(String date);

  /// Trip duration in hours
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String ownerHours(int count);

  /// No description provided for @ownerTotalRental.
  ///
  /// In en, this message translates to:
  /// **'Total rental'**
  String get ownerTotalRental;

  /// No description provided for @ownerPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform fee (10%)'**
  String get ownerPlatformFee;

  /// No description provided for @ownerYouReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get ownerYouReceive;

  /// No description provided for @ownerProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get ownerProcessing;

  /// No description provided for @ownerApproveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve request'**
  String get ownerApproveRequest;

  /// No description provided for @ownerRequestHandled.
  ///
  /// In en, this message translates to:
  /// **'This request has already been handled.'**
  String get ownerRequestHandled;

  /// No description provided for @ownerStatusPendingConfirm.
  ///
  /// In en, this message translates to:
  /// **'🟡 Awaiting confirmation'**
  String get ownerStatusPendingConfirm;

  /// No description provided for @ownerStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'✅ Confirmed'**
  String get ownerStatusConfirmed;

  /// No description provided for @ownerStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'🚗 Renting'**
  String get ownerStatusInProgress;

  /// No description provided for @ownerStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'✔ Completed'**
  String get ownerStatusCompleted;

  /// No description provided for @ownerStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'✖ Cancelled'**
  String get ownerStatusCancelled;

  /// No description provided for @ownerStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get ownerStatusUnknown;

  /// No description provided for @ownerRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue report'**
  String get ownerRevenueTitle;

  /// No description provided for @ownerRevenueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your income'**
  String get ownerRevenueSubtitle;

  /// No description provided for @ownerIncomeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Income this month'**
  String get ownerIncomeThisMonth;

  /// Number of paid trips this month
  ///
  /// In en, this message translates to:
  /// **'{count} paid trips'**
  String ownerPaidTrips(int count);

  /// No description provided for @ownerRevenueChart.
  ///
  /// In en, this message translates to:
  /// **'Revenue chart'**
  String get ownerRevenueChart;

  /// No description provided for @ownerNoRevenue.
  ///
  /// In en, this message translates to:
  /// **'No revenue in this period yet'**
  String get ownerNoRevenue;

  /// No description provided for @ownerRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get ownerRecentTransactions;

  /// No description provided for @ownerNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get ownerNoTransactions;

  /// No description provided for @ownerVehicleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the vehicle name'**
  String get ownerVehicleNameRequired;

  /// No description provided for @ownerVehiclePriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Rental price must be greater than 0'**
  String get ownerVehiclePriceInvalid;

  /// No description provided for @ownerVehicleCoordsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates'**
  String get ownerVehicleCoordsInvalid;

  /// No description provided for @ownerVehicleUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated successfully'**
  String get ownerVehicleUpdateSuccess;

  /// No description provided for @ownerVehicleCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle published successfully'**
  String get ownerVehicleCreateSuccess;

  /// No description provided for @ownerVehicleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get ownerVehicleEditTitle;

  /// No description provided for @ownerVehicleAddTitle.
  ///
  /// In en, this message translates to:
  /// **'List a new vehicle'**
  String get ownerVehicleAddTitle;

  /// No description provided for @ownerVehicleEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your vehicle\'s information'**
  String get ownerVehicleEditSubtitle;

  /// No description provided for @ownerVehicleAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to list your vehicle'**
  String get ownerVehicleAddSubtitle;

  /// No description provided for @ownerVehicleSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get ownerVehicleSaveChanges;

  /// No description provided for @ownerVehiclePublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get ownerVehiclePublish;

  /// No description provided for @ownerVehiclePhotos.
  ///
  /// In en, this message translates to:
  /// **'Vehicle photos'**
  String get ownerVehiclePhotos;

  /// No description provided for @ownerVehiclePhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 photos · The first is the cover'**
  String get ownerVehiclePhotosHint;

  /// No description provided for @ownerVehicleAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get ownerVehicleAddPhoto;

  /// No description provided for @ownerVehicleBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get ownerVehicleBasicInfo;

  /// No description provided for @ownerVehicleName.
  ///
  /// In en, this message translates to:
  /// **'Vehicle name'**
  String get ownerVehicleName;

  /// No description provided for @ownerVehicleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Toyota Camry 2024'**
  String get ownerVehicleNameHint;

  /// No description provided for @ownerVehiclePricePerHour.
  ///
  /// In en, this message translates to:
  /// **'Price/hour (VND)'**
  String get ownerVehiclePricePerHour;

  /// No description provided for @ownerVehiclePriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50000'**
  String get ownerVehiclePriceHint;

  /// No description provided for @ownerVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get ownerVehicleType;

  /// No description provided for @ownerVehicleLocation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle location'**
  String get ownerVehicleLocation;

  /// No description provided for @ownerVehicleLat.
  ///
  /// In en, this message translates to:
  /// **'Latitude (lat)'**
  String get ownerVehicleLat;

  /// No description provided for @ownerVehicleLatHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 21.0278'**
  String get ownerVehicleLatHint;

  /// No description provided for @ownerVehicleLng.
  ///
  /// In en, this message translates to:
  /// **'Longitude (lng)'**
  String get ownerVehicleLng;

  /// No description provided for @ownerVehicleLngHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 105.8342'**
  String get ownerVehicleLngHint;

  /// No description provided for @ownerVehicleMapSoon.
  ///
  /// In en, this message translates to:
  /// **'Picking a location on the map is coming soon.'**
  String get ownerVehicleMapSoon;

  /// No description provided for @ownerVehicleSpecs.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get ownerVehicleSpecs;

  /// No description provided for @ownerVehicleSpecsHint.
  ///
  /// In en, this message translates to:
  /// **'Can be left empty if not applicable (e.g. motorbike, bicycle).'**
  String get ownerVehicleSpecsHint;

  /// No description provided for @ownerVehicleSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get ownerVehicleSeats;

  /// No description provided for @ownerVehicleSeatsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get ownerVehicleSeatsHint;

  /// No description provided for @ownerVehicleDoors.
  ///
  /// In en, this message translates to:
  /// **'Doors'**
  String get ownerVehicleDoors;

  /// No description provided for @ownerVehicleDoorsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 4'**
  String get ownerVehicleDoorsHint;

  /// No description provided for @ownerVehicleTransmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get ownerVehicleTransmission;

  /// No description provided for @ownerVehicleCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get ownerVehicleCity;

  /// No description provided for @ownerVehicleCityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HCMC'**
  String get ownerVehicleCityHint;

  /// No description provided for @ownerVehicleDescription.
  ///
  /// In en, this message translates to:
  /// **'Vehicle description'**
  String get ownerVehicleDescription;

  /// No description provided for @ownerVehicleDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the condition and standout features...'**
  String get ownerVehicleDescriptionHint;

  /// No description provided for @ownerVehicleOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get ownerVehicleOptions;

  /// No description provided for @ownerVehicleEv.
  ///
  /// In en, this message translates to:
  /// **'Electric (EV)'**
  String get ownerVehicleEv;

  /// No description provided for @ownerVehicleEvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the EV badge on the listing'**
  String get ownerVehicleEvSubtitle;

  /// No description provided for @ownerVehicleDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow delivery to the customer\'s address'**
  String get ownerVehicleDeliverySubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
