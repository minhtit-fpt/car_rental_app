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
