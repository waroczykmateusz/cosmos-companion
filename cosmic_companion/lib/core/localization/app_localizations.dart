import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
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
    Locale('pl'),
  ];

  /// Nazwa aplikacji
  ///
  /// In pl, this message translates to:
  /// **'Cosmic Companion'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Niebo teraz'**
  String get dashboardTitle;

  /// No description provided for @moonPhaseLabel.
  ///
  /// In pl, this message translates to:
  /// **'Faza Księżyca'**
  String get moonPhaseLabel;

  /// No description provided for @moonPhaseNew.
  ///
  /// In pl, this message translates to:
  /// **'Nów'**
  String get moonPhaseNew;

  /// No description provided for @moonPhaseWaxingCrescent.
  ///
  /// In pl, this message translates to:
  /// **'Przybywający sierp'**
  String get moonPhaseWaxingCrescent;

  /// No description provided for @moonPhaseFirstQuarter.
  ///
  /// In pl, this message translates to:
  /// **'Pierwsza kwadra'**
  String get moonPhaseFirstQuarter;

  /// No description provided for @moonPhaseWaxingGibbous.
  ///
  /// In pl, this message translates to:
  /// **'Przybywający garb'**
  String get moonPhaseWaxingGibbous;

  /// No description provided for @moonPhaseFull.
  ///
  /// In pl, this message translates to:
  /// **'Pełnia'**
  String get moonPhaseFull;

  /// No description provided for @moonPhaseWaningGibbous.
  ///
  /// In pl, this message translates to:
  /// **'Ubywający garb'**
  String get moonPhaseWaningGibbous;

  /// No description provided for @moonPhaseLastQuarter.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnia kwadra'**
  String get moonPhaseLastQuarter;

  /// No description provided for @moonPhaseWaningCrescent.
  ///
  /// In pl, this message translates to:
  /// **'Ubywający sierp'**
  String get moonPhaseWaningCrescent;

  /// No description provided for @illuminationPercent.
  ///
  /// In pl, this message translates to:
  /// **'{value}% oświetlenia'**
  String illuminationPercent(int value);

  /// No description provided for @zodiacSignLabel.
  ///
  /// In pl, this message translates to:
  /// **'Księżyc w znaku'**
  String get zodiacSignLabel;

  /// No description provided for @seeingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Seeing'**
  String get seeingLabel;

  /// No description provided for @seeingExcellent.
  ///
  /// In pl, this message translates to:
  /// **'Doskonały'**
  String get seeingExcellent;

  /// No description provided for @seeingGood.
  ///
  /// In pl, this message translates to:
  /// **'Dobry'**
  String get seeingGood;

  /// No description provided for @seeingFair.
  ///
  /// In pl, this message translates to:
  /// **'Przeciętny'**
  String get seeingFair;

  /// No description provided for @seeingPoor.
  ///
  /// In pl, this message translates to:
  /// **'Słaby'**
  String get seeingPoor;

  /// No description provided for @seeingBad.
  ///
  /// In pl, this message translates to:
  /// **'Zły'**
  String get seeingBad;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wymagana lokalizacja'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja potrzebuje dostępu do lokalizacji, aby obliczać pozycje ciał niebieskich.'**
  String get locationPermissionMessage;

  /// No description provided for @nightModeNormal.
  ///
  /// In pl, this message translates to:
  /// **'Normalny'**
  String get nightModeNormal;

  /// No description provided for @nightModeDark.
  ///
  /// In pl, this message translates to:
  /// **'Noc'**
  String get nightModeDark;

  /// No description provided for @nightModeRed.
  ///
  /// In pl, this message translates to:
  /// **'Czerwony'**
  String get nightModeRed;

  /// No description provided for @onboardingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Witaj, obserwatorze'**
  String get onboardingTitle;

  /// No description provided for @onboardingNickLabel.
  ///
  /// In pl, this message translates to:
  /// **'Twój nick'**
  String get onboardingNickLabel;

  /// No description provided for @onboardingNickHint.
  ///
  /// In pl, this message translates to:
  /// **'np. StarHunter'**
  String get onboardingNickHint;

  /// No description provided for @pinSetupTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinLabel.
  ///
  /// In pl, this message translates to:
  /// **'PIN (4–6 cyfr)'**
  String get pinLabel;

  /// No description provided for @biometricSetupTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odcisk palca'**
  String get biometricSetupTitle;

  /// No description provided for @biometricSetupMessage.
  ///
  /// In pl, this message translates to:
  /// **'Czy chcesz włączyć odblokowanie odciskiem palca?'**
  String get biometricSetupMessage;

  /// No description provided for @lockScreenTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj'**
  String get lockScreenTitle;

  /// No description provided for @unlockWithBiometric.
  ///
  /// In pl, this message translates to:
  /// **'Użyj odcisku palca'**
  String get unlockWithBiometric;

  /// No description provided for @invalidPin.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy PIN'**
  String get invalidPin;

  /// No description provided for @weakPin.
  ///
  /// In pl, this message translates to:
  /// **'Ten PIN jest zbyt prosty'**
  String get weakPin;

  /// No description provided for @pinMismatch.
  ///
  /// In pl, this message translates to:
  /// **'PINy nie są zgodne'**
  String get pinMismatch;

  /// No description provided for @pinAttemptsLeft.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało prób: {count}'**
  String pinAttemptsLeft(int count);

  /// No description provided for @pinLockedOut.
  ///
  /// In pl, this message translates to:
  /// **'Konto zablokowane. Spróbuj za {seconds}s.'**
  String pinLockedOut(int seconds);

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @privacySettingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prywatność'**
  String get privacySettingsTitle;

  /// No description provided for @telemetryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Raporty o błędach'**
  String get telemetryLabel;

  /// No description provided for @telemetryDescription.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłaj anonimowe raporty o awariach (Sentry). Brak danych osobowych.'**
  String get telemetryDescription;

  /// No description provided for @deleteAllData.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wszystkie moje dane'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz trwale usunąć wszystkie dane? Tej operacji nie można cofnąć.'**
  String get deleteAllDataConfirm;

  /// No description provided for @aboutTitle.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get aboutTitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In pl, this message translates to:
  /// **'Regulamin'**
  String get termsOfService;

  /// No description provided for @ok.
  ///
  /// In pl, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź'**
  String get confirm;

  /// No description provided for @next.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In pl, this message translates to:
  /// **'Błąd'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In pl, this message translates to:
  /// **'Ładowanie…'**
  String get loading;

  /// No description provided for @yes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get no;

  String get equipmentTitle;
  String get equipmentNameLabel;
  String get equipmentTypeLabel;
  String get equipmentNotesLabel;
  String get equipmentTypeTelescope;
  String get equipmentTypeMount;
  String get equipmentTypeCamera;
  String get equipmentTypeEyepiece;
  String get equipmentTypeFilter;
  String get equipmentTypeOther;
  String get equipmentAdd;
  String get equipmentSave;
  String get equipmentDelete;
  String get equipmentDeleteConfirm;
  String get equipmentEmpty;
  String get lockAction;
  String get versionLabel;
  String get profileTitle;
  String get comingSoon;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
