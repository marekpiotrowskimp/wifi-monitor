# WiFi Monitor

Aplikacja **iOS + watchOS** do monitorowania połączenia Wi-Fi: siła sygnału, informacje o sieci, widgety na iPhonie i komplikacje na zegarku.

- SwiftUI, WidgetKit, App Groups (współdzielenie danych aplikacja ↔ widgety ↔ zegarek)
- projekt generowany przez [XcodeGen](https://github.com/yonaskolb/XcodeGen) z `project.yml`

## Build

```sh
xcodegen
open WifiMonitor.xcodeproj
```

Odczyt SSID na iOS wymaga uprawnienia *Access WiFi Information* i zgody na lokalizację.
Notatki z rozwoju: [SESSION_NOTES.md](SESSION_NOTES.md).
