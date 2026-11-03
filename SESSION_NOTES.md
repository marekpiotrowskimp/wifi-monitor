# WiFi Monitor - Notatki z sesji projektu

## Data ostatniej aktualizacji: 14 grudnia 2024

---

## Opis projektu

**WiFi Monitor** - aplikacja iOS i watchOS do monitorowania połączeń WiFi z widgetami i komplikacjami na zegarek.

---

## Struktura projektu

```
wifi/
├── project.yml                    # Konfiguracja XcodeGen (główny plik konfiguracyjny!)
├── WifiMonitor.xcodeproj/         # Generowany automatycznie przez XcodeGen
├── Shared/                        # Współdzielone między wszystkimi targets
│   ├── Models/
│   │   └── WiFiNetworkInfo.swift  # Model danych WiFi (Codable)
│   └── Services/
│       ├── WiFiService.swift      # Serwis monitorujący WiFi
│       ├── LocationManager.swift  # Zarządzanie lokalizacją
│       └── SharedDataManager.swift # App Groups - współdzielenie danych
├── WifiMonitor-iOS/               # Główna aplikacja iOS
│   ├── App/
│   │   └── WifiMonitorApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SignalStrengthBar.swift
│   │   └── NetworkInfoCard.swift
│   ├── ViewModels/
│   │   └── NetworkViewModel.swift
│   ├── Resources/Assets.xcassets/
│   ├── Info.plist
│   └── WifiMonitor-iOS.entitlements
├── WifiMonitor-watchOS/           # Główna aplikacja watchOS
│   ├── App/
│   │   └── WifiMonitorWatchApp.swift
│   ├── Views/
│   │   ├── WatchContentView.swift
│   │   ├── WatchSignalBar.swift
│   │   └── WatchNetworkInfo.swift
│   ├── ViewModels/
│   │   └── WatchNetworkViewModel.swift
│   ├── Resources/Assets.xcassets/
│   ├── Info.plist
│   └── WifiMonitor-watchOS.entitlements
├── WifiMonitorWidget/             # iOS Widget Extension
│   ├── WifiMonitorWidget.swift    # Główny plik widgetu
│   ├── WiFiWidgetEntry.swift      # Timeline Entry
│   ├── WiFiWidgetProvider.swift   # Timeline Provider
│   ├── Views/
│   │   ├── SmallWidgetView.swift
│   │   ├── MediumWidgetView.swift
│   │   ├── CircularWidgetView.swift
│   │   ├── RectangularWidgetView.swift
│   │   └── InlineWidgetView.swift
│   ├── Resources/Assets.xcassets/
│   ├── Info.plist
│   └── WifiMonitorWidget.entitlements
└── WifiMonitorWatchWidget/        # watchOS Widget Extension (Komplikacje)
    ├── WifiMonitorWatchWidget.swift
    ├── WatchWidgetEntry.swift
    ├── WatchWidgetProvider.swift
    ├── Views/
    │   ├── CornerComplicationView.swift
    │   ├── CircularComplicationView.swift
    │   ├── RectangularComplicationView.swift
    │   └── InlineComplicationView.swift
    ├── Resources/Assets.xcassets/
    ├── Info.plist
    └── WifiMonitorWatchWidget.entitlements
```

---

## Targets i Bundle Identifiers

| Target | Bundle ID | Platform | Typ |
|--------|-----------|----------|-----|
| WifiMonitor-iOS | com.marek.piotrowski.wifimonitor | iOS 17+ | application |
| WifiMonitorWidget | com.marek.piotrowski.wifimonitor.widget | iOS 17+ | app-extension |
| WifiMonitor-watchOS | com.marek.piotrowski.wifimonitor.watchkitapp | watchOS 10+ | application |
| WifiMonitorWatchWidget | com.marek.piotrowski.wifimonitor.watchkitapp.widget | watchOS 10+ | app-extension |

---

## App Groups

Wszystkie targets używają App Group: `group.com.marek.piotrowski.wifimonitor`

Służy do współdzielenia danych między aplikacją główną a widgetami.

---

## XcodeGen - Generator projektu

### Dlaczego XcodeGen?
- `project.pbxproj` jest trudny do ręcznej edycji i generuje konflikty w git
- `project.yml` jest czytelny, łatwy w edycji i wersjonowaniu
- Automatyczne zarządzanie plikami i zależnościami

### Instalacja
```bash
brew install xcodegen
```

### Użycie
```bash
# Regeneruj projekt po zmianach w project.yml:
cd wifi-monitor
xcodegen generate

# Otwórz w Xcode:
open WifiMonitor.xcodeproj
```

### Dodawanie nowych plików
1. Dodaj plik do odpowiedniego folderu
2. Uruchom `xcodegen generate`
3. Nowy plik zostanie automatycznie dodany do projektu

---

## Budowanie projektu

### iOS
```bash
xcodebuild -project WifiMonitor.xcodeproj \
  -scheme WifiMonitor-iOS \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### watchOS
```bash
xcodebuild -project WifiMonitor.xcodeproj \
  -scheme WifiMonitor-watchOS \
  -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  build
```

---

## Funkcjonalności

### Aplikacja iOS
- Wyświetlanie informacji o aktualnym połączeniu WiFi
- Nazwa sieci (SSID)
- Siła sygnału (wizualizacja)
- Adres IP
- Typ zabezpieczenia

### Aplikacja watchOS
- Kompaktowy widok informacji o WiFi
- Komplikacje na tarczy zegarka

### Widgety iOS
- **systemSmall** - mały widget z nazwą sieci i siłą sygnału
- **systemMedium** - średni widget z dodatkowymi informacjami
- **accessoryCircular** - okrągły widget na Lock Screen
- **accessoryRectangular** - prostokątny widget na Lock Screen
- **accessoryInline** - jednoliniowy widget

### Komplikacje watchOS
- **accessoryCorner** - komplikacja narożna
- **accessoryCircular** - komplikacja okrągła
- **accessoryRectangular** - komplikacja prostokątna
- **accessoryInline** - komplikacja jednoliniowa

---

## Wymagane uprawnienia (Info.plist)

- `NSLocationWhenInUseUsageDescription` - dostęp do lokalizacji (wymagany do odczytu SSID)
- `com.apple.developer.networking.wifi-info` - dostęp do informacji o WiFi

---

## Status projektu

- [x] Struktura folderów
- [x] Shared models i services
- [x] iOS app - UI i logika
- [x] watchOS app - UI i logika
- [x] iOS Widget Extension
- [x] watchOS Widget Extension (Komplikacje)
- [x] XcodeGen konfiguracja
- [x] Build iOS - SUCCEEDED
- [x] Build watchOS - SUCCEEDED
- [ ] Testowanie na fizycznych urządzeniach
- [ ] Ikony aplikacji
- [ ] App Store submission

---

## Znane problemy / TODO

1. **Development Team** - w `project.yml` jest pusty `DEVELOPMENT_TEAM: ""`. Przed budowaniem na fizyczne urządzenie trzeba ustawić swój Team ID.

2. **Ikony** - Assets.xcassets zawierają puste sloty na ikony. Trzeba dodać grafiki.

3. **WiFi API na symulatorze** - `NEHotspotNetwork` nie działa na symulatorze iOS. Testowanie wymaga fizycznego urządzenia.

---

## Przydatne komendy

```bash
# Lista dostępnych symulatorów iOS
xcrun simctl list devices | grep -i iphone

# Lista dostępnych symulatorów watchOS
xcrun simctl list devices | grep -i watch

# Wyczyść cache buildu
xcodebuild clean -project WifiMonitor.xcodeproj -alltargets

# Pokaż schematy
xcodebuild -list -project WifiMonitor.xcodeproj
```

---

## Historia zmian

### 14.12.2024
- Migracja z ręcznego `project.pbxproj` na XcodeGen
- Utworzenie `project.yml` z 4 targets
- Naprawienie Info.plist dla widget extensions
- Pomyślny build iOS i watchOS
