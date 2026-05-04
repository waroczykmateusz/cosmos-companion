// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cosmic Companion';

  @override
  String get dashboardTitle => 'Sky Now';

  @override
  String get moonPhaseLabel => 'Moon Phase';

  @override
  String get moonPhaseNew => 'New Moon';

  @override
  String get moonPhaseWaxingCrescent => 'Waxing Crescent';

  @override
  String get moonPhaseFirstQuarter => 'First Quarter';

  @override
  String get moonPhaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get moonPhaseFull => 'Full Moon';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseLastQuarter => 'Last Quarter';

  @override
  String get moonPhaseWaningCrescent => 'Waning Crescent';

  @override
  String illuminationPercent(int value) {
    return '$value% illuminated';
  }

  @override
  String get zodiacSignLabel => 'Moon Sign';

  @override
  String get seeingLabel => 'Seeing';

  @override
  String get seeingExcellent => 'Excellent';

  @override
  String get seeingGood => 'Good';

  @override
  String get seeingFair => 'Fair';

  @override
  String get seeingPoor => 'Poor';

  @override
  String get seeingBad => 'Bad';

  @override
  String get locationPermissionRequired => 'Location required';

  @override
  String get locationPermissionMessage =>
      'The app needs location access to compute celestial body positions.';

  @override
  String get nightModeNormal => 'Normal';

  @override
  String get nightModeDark => 'Night';

  @override
  String get nightModeRed => 'Red';

  @override
  String get onboardingTitle => 'Welcome, observer';

  @override
  String get onboardingNickLabel => 'Your nickname';

  @override
  String get onboardingNickHint => 'e.g. StarHunter';

  @override
  String get pinSetupTitle => 'Set PIN';

  @override
  String get pinConfirmTitle => 'Confirm PIN';

  @override
  String get pinLabel => 'PIN (4–6 digits)';

  @override
  String get biometricSetupTitle => 'Fingerprint';

  @override
  String get biometricSetupMessage =>
      'Would you like to enable fingerprint unlock?';

  @override
  String get lockScreenTitle => 'Unlock';

  @override
  String get unlockWithBiometric => 'Use fingerprint';

  @override
  String get invalidPin => 'Invalid PIN';

  @override
  String get weakPin => 'This PIN is too simple';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String pinAttemptsLeft(int count) {
    return 'Attempts left: $count';
  }

  @override
  String pinLockedOut(int seconds) {
    return 'Locked out. Try again in ${seconds}s.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get privacySettingsTitle => 'Privacy';

  @override
  String get telemetryLabel => 'Crash reports';

  @override
  String get telemetryDescription =>
      'Send anonymous crash reports (Sentry). No personal data included.';

  @override
  String get deleteAllData => 'Delete all my data';

  @override
  String get deleteAllDataConfirm =>
      'Are you sure you want to permanently delete all data? This cannot be undone.';

  @override
  String get aboutTitle => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading…';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get equipmentTitle => 'Equipment';

  @override
  String get equipmentNameLabel => 'Name';

  @override
  String get equipmentTypeLabel => 'Type';

  @override
  String get equipmentNotesLabel => 'Notes';

  @override
  String get equipmentTypeTelescope => 'Telescope';

  @override
  String get equipmentTypeMount => 'Mount';

  @override
  String get equipmentTypeCamera => 'Camera';

  @override
  String get equipmentTypeEyepiece => 'Eyepiece';

  @override
  String get equipmentTypeFilter => 'Filter';

  @override
  String get equipmentTypeOther => 'Other';

  @override
  String get equipmentAdd => 'Add equipment';

  @override
  String get equipmentSave => 'Save';

  @override
  String get equipmentDelete => 'Delete';

  @override
  String get equipmentDeleteConfirm => 'Delete this item?';

  @override
  String get equipmentEmpty =>
      'No equipment added yet. Add a telescope, mount or camera.';

  @override
  String get lockAction => 'Lock';

  @override
  String get versionLabel => 'Version';

  @override
  String get profileTitle => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarNoEvents => 'No events this month';

  @override
  String get calendarMoonPhaseEvent => 'Moon Phase';

  @override
  String planetaryIngressEvent(String body, String sign) {
    return '$body enters $sign';
  }

  @override
  String get calendarLabelMoonIngress => 'Moon changes sign';

  @override
  String get calendarLabelPlanetIngress => 'Planetary ingress';

  @override
  String get mapTitle => 'Sky Map';

  @override
  String get bortleScaleTitle => 'Bortle Scale';

  @override
  String get lightPollutionOverlay => 'Light pollution overlay';

  @override
  String get bortleEstimateLabel => 'Estimated level';

  @override
  String get darkSkyTip => 'Look for Bortle ≤4 sites for astrophotography.';

  @override
  String get planetsSectionTitle => 'Planets today';

  @override
  String aboveHorizon(String deg) {
    return 'Alt $deg°';
  }

  @override
  String get belowHorizon => 'Below horizon';

  @override
  String get horoscopeWheelTitle => 'Planet positions';

  @override
  String get riseLabel => 'Rise';

  @override
  String get transitLabel => 'Transit';

  @override
  String get setLabel => 'Set';

  @override
  String get altitudeLabel => 'Alt.';

  @override
  String get azimuthLabel => 'Az.';

  @override
  String get eclipticLonLabel => 'Ecl.';

  @override
  String get distanceLabel => 'Dist.';

  @override
  String get magnitudeLabel => 'Mag.';

  @override
  String get solarSystemTitle => 'Solar System';
}
