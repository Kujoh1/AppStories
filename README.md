# AppStories

Eine interaktive Flutter-App, die wie ein Buch mit verzweigenden Geschichten funktioniert.

## Features

- ✨ **Material 3 Design** - Modernes UI mit Light/Dark Theme
- 📖 **Interaktive Geschichten** - 10 Kapitel mit Branching-Unterstützung
- 🎯 **Saubere Architektur** - Features, Domain, Data, Core Struktur
- 🔄 **State Management** - Riverpod für reaktive State-Verwaltung
- 🧭 **Navigation** - go_router für Deep Links und saubere Routen
- 🎨 **Interaktive Text-Features** - Zoom, TextScale, Font-Anpassungen vorbereitet
- 📱 **Responsive Design** - Optimiert für verschiedene Bildschirmgrößen

## Architektur

```
lib/
├── core/                    # Shared resources
│   ├── constants/          # App-wide constants
│   ├── router/             # Navigation configuration
│   ├── theme/              # Theme & styling
│   └── widgets/            # Reusable widgets
├── data/                   # Data layer
│   └── repositories/       # Data access
├── domain/                 # Business logic
│   └── models/             # Domain models
└── features/               # Feature modules
    └── reader/
        ├── presentation/   # UI layer
        │   ├── pages/
        │   └── widgets/
        └── providers/      # State management
```

## Projekt-Struktur Details

### Domain Models
- **StoryPage**: Repräsentiert eine einzelne Seite/Kapitel
- **Choice**: Verzweigungspunkte in der Geschichte
- **BookGraph**: Gesamte Geschichte als Graph-Struktur

### Features
- **Home Page**: Startseite mit Buchübersicht
- **Reader Page**: Hauptleser-Interface mit:
  - Top-Bar mit Fortschrittsanzeige
  - Interaktiver Text-Container
  - Navigation (Vor/Zurück)
  - Branching-Choices (Kapitel 3 Demo)
  - Einstellungen (TextScale, Zoom)

### Branching Demo
Kapitel 3 zeigt das Branching-System:
- **Choice A**: Führt zu Kapitel 4 (Bergpfad)
- **Choice B**: Führt zu Kapitel 5 (Flusslauf)
- **Choice C**: Führt zu Kapitel 6 (Dunkler Wald)

## Installation

1. Flutter SDK installieren (3.0+)
2. Dependencies installieren:
```bash
flutter pub get
```

3. App starten:
```bash
flutter run
```

## Verwendete Packages

- `flutter_riverpod` - State Management
- `go_router` - Navigation & Routing
- `riverpod_annotation` - Code Generation für Riverpod

## Nächste Schritte

- [ ] Echte Inhalte für alle 10 Kapitel
- [ ] Pinch-to-Zoom Gesten implementieren
- [ ] Font-Family Auswahl
- [ ] Lesezeichen/Progress Speicherung
- [ ] Animationen zwischen Seiten
- [ ] Bilder/Illustrationen Support
- [ ] Audio/Sound-Effekte
- [ ] Mehrere Bücher/Geschichten

## Entwickelt mit

- Flutter 3.x
- Material Design 3
- Clean Architecture Prinzipien

## Lizenz

MIT License


