import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('si'),
    Locale('ta')
  ];

  /// The current Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// A programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// Travel
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get apNameText;

  /// introductionOneText
  ///
  /// In en, this message translates to:
  /// **'Organize anything with anyone anywhere.'**
  String get introductionOneText;

  /// introductionTwoText
  ///
  /// In en, this message translates to:
  /// **'Enhanced in-app communication.'**
  String get introductionTwoText;

  /// introductionThreeText
  ///
  /// In en, this message translates to:
  /// **'Stay in the know - even on the go.'**
  String get introductionThreeText;

  /// nextText
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextText;

  /// skipText
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipText;

  /// signUpText
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpText;

  /// loginText
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginText;

  /// alreadyHaveAnAccountText
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccountText;

  /// welcomeText
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeText;

  /// userNameText
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userNameText;

  /// tenantHint
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordText;

  /// No description provided for @tenantHint.
  ///
  /// In en, this message translates to:
  /// **'Tenant/Company'**
  String get tenantHint;

  /// rememberMeText
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMeText;

  /// doNotHaveAccountText
  ///
  /// In en, this message translates to:
  /// **'Don\'t have account?'**
  String get doNotHaveAccountText;

  /// emailText
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailText;

  /// countryText
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryText;

  /// birthdayText
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthdayText;

  /// iAgreeToAllTermsText
  ///
  /// In en, this message translates to:
  /// **'I agree to all terms'**
  String get iAgreeToAllTermsText;

  /// fullNameText
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameText;

  /// emailAddressText
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressText;

  /// emailOrUsernameText
  ///
  /// In en, this message translates to:
  /// **'Email / UserName'**
  String get emailOrUsernameText;

  /// iAgreeToReceiveNewslettersText
  ///
  /// In en, this message translates to:
  /// **'I agree to receive newsletters'**
  String get iAgreeToReceiveNewslettersText;

  /// subscribeText
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeText;

  /// categoryText
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryText;

  /// homeText
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeText;

  /// searchText
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchText;

  /// profileText
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileText;

  /// readMoreText
  ///
  /// In en, this message translates to:
  /// **'Read More...'**
  String get readMoreText;

  /// readLessText
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLessText;

  /// searchForText
  ///
  /// In en, this message translates to:
  /// **'Search for...'**
  String get searchForText;

  /// settingsText
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsText;

  /// logoutText
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutText;

  /// termsText
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsText;

  /// menuText
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuText;

  /// myAccountText
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccountText;

  /// notificationText
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationText;

  /// languageText
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageText;

  /// faqText
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqText;

  /// privacyPolicyText
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyText;

  /// termsConditionsText
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditionsText;

  /// contactUsText
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsText;

  /// noNotificationFoundText
  ///
  /// In en, this message translates to:
  /// **'No notification found'**
  String get noNotificationFoundText;

  /// notificationSubTitleText
  ///
  /// In en, this message translates to:
  /// **'We did not found any notification'**
  String get notificationSubTitleText;

  /// notificationSubTitle2Text
  ///
  /// In en, this message translates to:
  /// **'Lets start exploring'**
  String get notificationSubTitle2Text;

  /// newText
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newText;

  /// companyName
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// signIn
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// pinCode
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// forgetPw
  ///
  /// In en, this message translates to:
  /// **'Forgot Password ?'**
  String get forgetPw;

  /// click
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get click;

  /// epfnumber
  ///
  /// In en, this message translates to:
  /// **'EPF Number'**
  String get epfnumber;

  /// viewMore
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// checkIn
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// checkOut
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// leaveText
  ///
  /// In en, this message translates to:
  /// **'My Leaves'**
  String get leaveText;

  /// attendanceText
  ///
  /// In en, this message translates to:
  /// **'My Attendance'**
  String get attendanceText;

  /// continueText
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// leaveRequest
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get leaveRequest;

  /// submit
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// apply
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// rosterText
  ///
  /// In en, this message translates to:
  /// **'My Roster'**
  String get rosterText;

  /// emailValidation
  ///
  /// In en, this message translates to:
  /// **'Please enter email address'**
  String get emailValidation;

  /// tenantValidation
  ///
  /// In en, this message translates to:
  /// **'Please enter company name'**
  String get tenantValidation;

  /// epfValidation
  ///
  /// In en, this message translates to:
  /// **'Please enter epf number'**
  String get epfValidation;

  /// pinCodeValidation
  ///
  /// In en, this message translates to:
  /// **'Please enter pin code'**
  String get pinCodeValidation;

  /// January
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// February
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// March
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// April
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// June
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// July
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// August
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// September
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// October
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// November
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// December
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// Leave Approve
  ///
  /// In en, this message translates to:
  /// **'Leave Approve'**
  String get leaveApprove;

  /// Leave Reject
  ///
  /// In en, this message translates to:
  /// **'Leave Reject'**
  String get leaveReject;

  /// No description provided for @salarySlips.
  ///
  /// In en, this message translates to:
  /// **'Salary Slips'**
  String get salarySlips;

  /// No description provided for @salarySlipHistory.
  ///
  /// In en, this message translates to:
  /// **'Salary Slip History'**
  String get salarySlipHistory;

  /// No description provided for @salarySlipLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary Slip'**
  String get salarySlipLabel;

  /// No description provided for @htmlPreviewNotWired.
  ///
  /// In en, this message translates to:
  /// **'HTML preview is not wired yet.'**
  String get htmlPreviewNotWired;

  /// No description provided for @thisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthLabel;

  /// No description provided for @pastMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Past Month'**
  String get pastMonthLabel;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noRecords;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @nic.
  ///
  /// In en, this message translates to:
  /// **'NIC'**
  String get nic;

  /// No description provided for @ssoLogin.
  ///
  /// In en, this message translates to:
  /// **'SSO Login'**
  String get ssoLogin;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully'**
  String get profilePictureUpdated;

  /// No description provided for @failedToUpdatePicture.
  ///
  /// In en, this message translates to:
  /// **'Failed to update picture'**
  String get failedToUpdatePicture;

  /// No description provided for @confirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @leaveRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get leaveRequestLabel;

  /// No description provided for @leaveDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave Details'**
  String get leaveDetailsLabel;

  /// No description provided for @confirmLeave.
  ///
  /// In en, this message translates to:
  /// **'Confirm Leave'**
  String get confirmLeave;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysLabel;

  /// No description provided for @leaveTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leaveTypeLabel;

  /// No description provided for @annualLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annualLabel;

  /// No description provided for @casualLabel.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get casualLabel;

  /// No description provided for @medicalLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medicalLabel;

  /// No description provided for @leaveMode.
  ///
  /// In en, this message translates to:
  /// **'Leave Mode'**
  String get leaveMode;

  /// No description provided for @fullDay.
  ///
  /// In en, this message translates to:
  /// **'Full Day'**
  String get fullDay;

  /// No description provided for @halfDay.
  ///
  /// In en, this message translates to:
  /// **'Half Day'**
  String get halfDay;

  /// No description provided for @alternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get alternative;

  /// No description provided for @fromToDescription.
  ///
  /// In en, this message translates to:
  /// **'Select start and end dates'**
  String get fromToDescription;

  /// No description provided for @leaveBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Balances'**
  String get leaveBalanceTitle;

  /// No description provided for @attendanceForThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Attendance for this Month'**
  String get attendanceForThisMonth;

  /// No description provided for @presentLabel.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentLabel;

  /// No description provided for @absentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Absents'**
  String get absentsLabel;

  /// No description provided for @lateInLabel.
  ///
  /// In en, this message translates to:
  /// **'Late in'**
  String get lateInLabel;

  /// No description provided for @dayOffLabel.
  ///
  /// In en, this message translates to:
  /// **'DayOff'**
  String get dayOffLabel;

  /// No description provided for @shiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shiftLabel;

  /// No description provided for @inLabel.
  ///
  /// In en, this message translates to:
  /// **'IN :'**
  String get inLabel;

  /// No description provided for @outLabel.
  ///
  /// In en, this message translates to:
  /// **'OUT :'**
  String get outLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @workedHeader.
  ///
  /// In en, this message translates to:
  /// **'WORKED'**
  String get workedHeader;

  /// No description provided for @lateHeader.
  ///
  /// In en, this message translates to:
  /// **'LATE'**
  String get lateHeader;

  /// No description provided for @overHeader.
  ///
  /// In en, this message translates to:
  /// **'OVER'**
  String get overHeader;

  /// No description provided for @allowanceDeductions.
  ///
  /// In en, this message translates to:
  /// **'Allowances & Deductions'**
  String get allowanceDeductions;

  /// No description provided for @debtLoans.
  ///
  /// In en, this message translates to:
  /// **'Debts & Loans'**
  String get debtLoans;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @epfLabel.
  ///
  /// In en, this message translates to:
  /// **'EPF: '**
  String get epfLabel;

  /// No description provided for @notAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get notAdded;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @nicLabel.
  ///
  /// In en, this message translates to:
  /// **'NIC'**
  String get nicLabel;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @fromToLabel.
  ///
  /// In en, this message translates to:
  /// **'From / To'**
  String get fromToLabel;

  /// No description provided for @cannotSelectPastDate.
  ///
  /// In en, this message translates to:
  /// **'Cannot select a past date'**
  String get cannotSelectPastDate;

  /// No description provided for @fromDateCannotBeAfterTo.
  ///
  /// In en, this message translates to:
  /// **'From date cannot be after To date'**
  String get fromDateCannotBeAfterTo;

  /// No description provided for @toDateMustBeAfterFrom.
  ///
  /// In en, this message translates to:
  /// **'To date must be after From date'**
  String get toDateMustBeAfterFrom;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @leaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Leave History'**
  String get leaveHistory;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @allowancesLabel.
  ///
  /// In en, this message translates to:
  /// **'Allowances'**
  String get allowancesLabel;

  /// No description provided for @deductionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get deductionsLabel;

  /// No description provided for @noAllowancesFound.
  ///
  /// In en, this message translates to:
  /// **'No allowances found'**
  String get noAllowancesFound;

  /// No description provided for @noDeductionsFound.
  ///
  /// In en, this message translates to:
  /// **'No deductions found'**
  String get noDeductionsFound;

  /// No description provided for @processedLabel.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processedLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @debtsLabel.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debtsLabel;

  /// No description provided for @loansLabel.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansLabel;

  /// No description provided for @noDebtsFound.
  ///
  /// In en, this message translates to:
  /// **'No debts found'**
  String get noDebtsFound;

  /// No description provided for @noLoansFound.
  ///
  /// In en, this message translates to:
  /// **'No loans found'**
  String get noLoansFound;

  /// No description provided for @collectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collectedLabel;
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
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
