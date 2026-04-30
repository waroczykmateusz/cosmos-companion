# Exporters (FUTURE)

Eksport danych sesji obserwacyjnych do formatów zewnętrznych aplikacji astronomicznych.

**Planowane formaty:**
- Stellarium `.fov` — lista obiektów do obserwacji
- SkySafari `.ssc` — listy obserwacyjne
- TIFF EXIF — metadata astrofotografii (RA/Dec, ogniskowa, lokalizacja)

**Plan implementacji:**
- Osobna klasa per format: `StellariumExporter`, `SkySafariExporter`, `TiffExifExporter`
- Integracja z `share_plus` do udostępniania plików

**Zarezerwowane dependency (pubspec.yaml):**
```yaml
# share_plus: ^9.x
```
