# AR Sky Map (FUTURE)

Widok AR nieba przez kamerę — identyfikacja gwiazd, planet i konstelacji w czasie rzeczywistym.

**Plan implementacji:**
- arcore_flutter_plugin (Android) + arkit_plugin (iOS)
- Sensor fusion: akcelerometr + żyroskop + magnetometr → orientacja telefonu
- Render: projekcja ciał niebieskich na widok kamery

**Zarezerwowane w manifeście:**
Camera permission zadeklarowana w AndroidManifest.xml i Info.plist od MVP.
Prośba o permission pojawia się dopiero przy wejściu do tej funkcji (nie przy starcie app).

**Zarezerwowane dependency (pubspec.yaml):**
```yaml
# arcore_flutter_plugin: ^0.x
# arkit_plugin: ^1.x
```
