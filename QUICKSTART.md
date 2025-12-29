# AppStories - Schnellstart-Anleitung

## Voraussetzungen

- Flutter SDK 3.0 oder höher
- Dart SDK 3.0 oder höher
- Android Studio / VS Code mit Flutter-Erweiterung
- Git (optional)

## Installation

### 1. Projekt-Setup

```bash
# Dependencies installieren
flutter pub get

# Prüfen ob alles funktioniert
flutter doctor
```

### 2. App starten

#### Desktop (Windows/macOS/Linux)
```bash
flutter run -d windows
# oder
flutter run -d macos
# oder
flutter run -d linux
```

#### Mobile (Android/iOS)
```bash
# Android Emulator starten, dann:
flutter run -d android

# iOS Simulator starten, dann:
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

## Projekt-Struktur

```
lib/
├── main.dart                           # App Entry Point
├── core/                               # Shared Resources
│   ├── constants/app_constants.dart   # App-weite Konstanten
│   ├── router/app_router.dart         # Navigation (go_router)
│   ├── theme/app_theme.dart           # Material 3 Theme
│   └── widgets/                       # Wiederverwendbare Widgets
├── domain/                            # Business Logic
│   └── models/                        # Datenmodelle
├── data/                              # Data Layer
│   └── repositories/                  # Datenzugriff
└── features/                          # Feature Modules
    └── reader/                        # Reader Feature
        ├── providers/                 # State Management
        └── presentation/              # UI Layer
```

## Erste Schritte

### 1. App erkunden

Nach dem Start siehst du:
- **Home Page**: Übersicht mit Buch-Info und Start-Button
- **Reader Page**: Hauptleser-Interface mit Navigation

### 2. Navigation testen

- Klicke auf "Geschichte starten" auf der Home Page
- Nutze "Weiter"/"Zurück" Buttons zur Navigation
- Navigiere zu Kapitel 3 um Branching zu sehen

### 3. Branching-Demo (Kapitel 3)

Kapitel 3 zeigt das Branching-System:
- **Choice A**: Bergpfad → führt zu Kapitel 4
- **Choice B**: Flusslauf → führt zu Kapitel 5
- **Choice C**: Dunkler Wald → führt zu Kapitel 6

### 4. Einstellungen testen

- Klicke auf das Settings-Icon (⚙️) in der Top-Bar
- Passe die Textgröße mit dem Slider an (80% - 200%)
- Klicke "Zurücksetzen" um Standardwerte wiederherzustellen

### 5. Interaktive Features

- **Double-Tap** auf Text: Zoom Toggle (1x ↔ 1.5x)
- **Text-Auswahl**: Selektiere Text zum Kopieren
- **Smooth Animations**: Beobachte die Übergänge

## Entwicklung

### Code-Änderungen

#### Neue Seite hinzufügen

Öffne `lib/data/repositories/book_repository.dart`:

```dart
'page_11': const StoryPage(
  id: 'page_11',
  title: 'Kapitel 11: Dein Titel',
  content: '''
Dein Inhalt hier...
  ''',
  displayOrder: 11,
  isPlaceholder: false,
),
```

#### Branching hinzufügen

```dart
StoryPage(
  id: 'page_x',
  title: 'Kapitel mit Choices',
  content: 'Inhalt...',
  displayOrder: x,
  choices: const [
    Choice(
      id: 'choice_x1',
      text: 'Option 1',
      nextPageId: 'page_y',
      description: 'Beschreibung optional',
    ),
    Choice(
      id: 'choice_x2',
      text: 'Option 2',
      nextPageId: 'page_z',
    ),
  ],
),
```

### Hot Reload

Flutter unterstützt Hot Reload für schnelle Entwicklung:
- **Hot Reload**: `r` in Terminal oder `Ctrl+S` in IDE
- **Hot Restart**: `R` in Terminal oder `Ctrl+Shift+S` in IDE

### Debugging

```bash
# Debug-Modus mit Logs
flutter run --debug

# Performance-Profiling
flutter run --profile

# Release-Build testen
flutter run --release
```

## Theme anpassen

Öffne `lib/core/theme/app_theme.dart`:

```dart
// Primärfarbe ändern
static const _primaryColor = Color(0xFF6750A4); // Deine Farbe

// Weitere Anpassungen in lightTheme/darkTheme
```

## State Management

### Riverpod Provider verwenden

```dart
// In einem Widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider lesen
    final book = ref.watch(bookProvider);
    
    // Provider-Methode aufrufen
    ref.read(readerStateProvider('page_1').notifier).setTextScale(1.5);
    
    return ...;
  }
}
```

## Häufige Aufgaben

### Neue Route hinzufügen

In `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/my-route',
  name: 'myRoute',
  builder: (context, state) => MyPage(),
),
```

### Neue Konstante hinzufügen

In `lib/core/constants/app_constants.dart`:

```dart
static const double myConstant = 42.0;
```

### Neues Widget erstellen

```dart
// lib/core/widgets/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('My Widget'),
    );
  }
}
```

## Testing

### Unit Tests ausführen

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter test integration_test/
```

## Build & Deployment

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# APK befindet sich in: build/app/outputs/flutter-apk/
```

### iOS App

```bash
# Release Build
flutter build ios --release

# Öffne Xcode für weitere Schritte
open ios/Runner.xcworkspace
```

### Web

```bash
# Release Build
flutter build web --release

# Output in: build/web/
```

## Troubleshooting

### Dependencies-Probleme

```bash
# Cache löschen und neu installieren
flutter clean
flutter pub get
```

### Build-Fehler

```bash
# Rebuild
flutter clean
flutter pub get
flutter run
```

### Linter-Fehler

```bash
# Linter ausführen
flutter analyze

# Auto-Fix (wo möglich)
dart fix --apply
```

## Nützliche Befehle

```bash
# Flutter Version anzeigen
flutter --version

# Verfügbare Geräte anzeigen
flutter devices

# Logs anzeigen
flutter logs

# Performance-Overlay
flutter run --trace-startup

# Dependency-Updates prüfen
flutter pub outdated
```

## Weitere Ressourcen

- [Flutter Dokumentation](https://docs.flutter.dev/)
- [Riverpod Dokumentation](https://riverpod.dev/)
- [go_router Dokumentation](https://pub.dev/packages/go_router)
- [Material 3 Design](https://m3.material.io/)

## Support

Bei Fragen oder Problemen:
1. Prüfe die `ARCHITECTURE.md` für Details zur Architektur
2. Schaue in die Code-Kommentare
3. Nutze Flutter DevTools für Debugging

## Nächste Schritte

1. ✅ Projekt läuft
2. ✅ Navigation funktioniert
3. ✅ Branching verstanden
4. 📝 Eigene Inhalte hinzufügen
5. 🎨 Theme anpassen
6. 🚀 Neue Features entwickeln

Viel Erfolg mit AppStories! 🎉


