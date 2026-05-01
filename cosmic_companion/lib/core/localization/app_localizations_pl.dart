// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Cosmic Companion';

  @override
  String get dashboardTitle => 'Niebo teraz';

  @override
  String get moonPhaseLabel => 'Faza Księżyca';

  @override
  String get moonPhaseNew => 'Nów';

  @override
  String get moonPhaseWaxingCrescent => 'Przybywający sierp';

  @override
  String get moonPhaseFirstQuarter => 'Pierwsza kwadra';

  @override
  String get moonPhaseWaxingGibbous => 'Przybywający garb';

  @override
  String get moonPhaseFull => 'Pełnia';

  @override
  String get moonPhaseWaningGibbous => 'Ubywający garb';

  @override
  String get moonPhaseLastQuarter => 'Ostatnia kwadra';

  @override
  String get moonPhaseWaningCrescent => 'Ubywający sierp';

  @override
  String illuminationPercent(int value) {
    return '$value% oświetlenia';
  }

  @override
  String get zodiacSignLabel => 'Księżyc w znaku';

  @override
  String get seeingLabel => 'Seeing';

  @override
  String get seeingExcellent => 'Doskonały';

  @override
  String get seeingGood => 'Dobry';

  @override
  String get seeingFair => 'Przeciętny';

  @override
  String get seeingPoor => 'Słaby';

  @override
  String get seeingBad => 'Zły';

  @override
  String get locationPermissionRequired => 'Wymagana lokalizacja';

  @override
  String get locationPermissionMessage =>
      'Aplikacja potrzebuje dostępu do lokalizacji, aby obliczać pozycje ciał niebieskich.';

  @override
  String get nightModeNormal => 'Normalny';

  @override
  String get nightModeDark => 'Noc';

  @override
  String get nightModeRed => 'Czerwony';

  @override
  String get onboardingTitle => 'Witaj, obserwatorze';

  @override
  String get onboardingNickLabel => 'Twój nick';

  @override
  String get onboardingNickHint => 'np. StarHunter';

  @override
  String get pinSetupTitle => 'Ustaw PIN';

  @override
  String get pinConfirmTitle => 'Potwierdź PIN';

  @override
  String get pinLabel => 'PIN (4–6 cyfr)';

  @override
  String get biometricSetupTitle => 'Odcisk palca';

  @override
  String get biometricSetupMessage =>
      'Czy chcesz włączyć odblokowanie odciskiem palca?';

  @override
  String get lockScreenTitle => 'Odblokuj';

  @override
  String get unlockWithBiometric => 'Użyj odcisku palca';

  @override
  String get invalidPin => 'Nieprawidłowy PIN';

  @override
  String get weakPin => 'Ten PIN jest zbyt prosty';

  @override
  String get pinMismatch => 'PINy nie są zgodne';

  @override
  String pinAttemptsLeft(int count) {
    return 'Pozostało prób: $count';
  }

  @override
  String pinLockedOut(int seconds) {
    return 'Konto zablokowane. Spróbuj za ${seconds}s.';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get privacySettingsTitle => 'Prywatność';

  @override
  String get telemetryLabel => 'Raporty o błędach';

  @override
  String get telemetryDescription =>
      'Wysyłaj anonimowe raporty o awariach (Sentry). Brak danych osobowych.';

  @override
  String get deleteAllData => 'Usuń wszystkie moje dane';

  @override
  String get deleteAllDataConfirm =>
      'Czy na pewno chcesz trwale usunąć wszystkie dane? Tej operacji nie można cofnąć.';

  @override
  String get aboutTitle => 'O aplikacji';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get termsOfService => 'Regulamin';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anuluj';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get next => 'Dalej';

  @override
  String get skip => 'Pomiń';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get error => 'Błąd';

  @override
  String get loading => 'Ładowanie…';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get equipmentTitle => 'Sprzęt';

  @override
  String get equipmentNameLabel => 'Nazwa';

  @override
  String get equipmentTypeLabel => 'Typ';

  @override
  String get equipmentNotesLabel => 'Notatki';

  @override
  String get equipmentTypeTelescope => 'Teleskop';

  @override
  String get equipmentTypeMount => 'Montaż';

  @override
  String get equipmentTypeCamera => 'Aparat';

  @override
  String get equipmentTypeEyepiece => 'Okular';

  @override
  String get equipmentTypeFilter => 'Filtr';

  @override
  String get equipmentTypeOther => 'Inne';

  @override
  String get equipmentAdd => 'Dodaj sprzęt';

  @override
  String get equipmentSave => 'Zapisz';

  @override
  String get equipmentDelete => 'Usuń';

  @override
  String get equipmentDeleteConfirm => 'Usunąć ten element?';

  @override
  String get equipmentEmpty =>
      'Brak sprzętu. Dodaj teleskop, montaż lub aparat.';

  @override
  String get lockAction => 'Zablokuj';

  @override
  String get versionLabel => 'Wersja';

  @override
  String get profileTitle => 'Profil';

  @override
  String get comingSoon => 'Dostępne wkrótce';

  @override
  String get calendarTitle => 'Kalendarz';

  @override
  String get calendarNoEvents => 'Brak wydarzeń w tym miesiącu';

  @override
  String get calendarMoonPhaseEvent => 'Faza Księżyca';

  @override
  String planetaryIngressEvent(String body, String sign) {
    return '$body wchodzi w $sign';
  }

  @override
  String get calendarLabelMoonIngress => 'Księżyc zmienia znak';

  @override
  String get calendarLabelPlanetIngress => 'Ingres planetarny';

  @override
  String get mapTitle => 'Mapa nieba';

  @override
  String get bortleScaleTitle => 'Skala Bortle';

  @override
  String get lightPollutionOverlay => 'Nakładka zanieczyszczenia światłem';

  @override
  String get bortleEstimateLabel => 'Szacowany poziom';

  @override
  String get darkSkyTip => 'Szukaj miejsc z Bortle ≤4 dla astrofotografii.';

  @override
  String get planetsSectionTitle => 'Planety dziś';

  @override
  String aboveHorizon(String deg) {
    return 'Alt $deg°';
  }

  @override
  String get belowHorizon => 'Pod horyzontem';
}
