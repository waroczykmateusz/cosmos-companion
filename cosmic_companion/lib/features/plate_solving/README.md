# Plate Solving (FUTURE)

Offline plate solving — dopasowywanie zdjęć do gwiazd bez internetu.

**Plan implementacji:**
- FFI binding do astrometry.net C lib lub tetra3 port
- Katalog Tycho-2 ściągany on-demand (cache lokalny)
- Input: JPEG/TIFF z astrofotografii → output: RA/Dec center + orientacja

**Zarezerwowane dependency (pubspec.yaml):**
Brak na razie — wybór biblioteki do oceny przy implementacji.
