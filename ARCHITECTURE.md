# AppStories - Architektur-Dokumentation

## Übersicht

AppStories ist eine interaktive Flutter-App mit Material 3 Design, die wie ein Buch mit verzweigenden Geschichten funktioniert. Die App folgt Clean Architecture Prinzipien mit klarer Trennung von Verantwortlichkeiten.

## Architektur-Layers

### 1. Domain Layer (`lib/domain/`)
Der Domain Layer enthält die Geschäftslogik und Datenmodelle, unabhängig von Framework und UI.

#### Models
- **`StoryPage`**: Repräsentiert eine einzelne Seite/Kapitel
  - `id`: Eindeutige Seiten-ID
  - `title`: Kapitel-Titel
  - `content`: Text-Inhalt der Seite
  - `choices`: Liste von Verzweigungsoptionen
  - `displayOrder`: Reihenfolge für lineare Navigation
  - `isPlaceholder`: Markierung für Platzhalter-Seiten

- **`Choice`**: Repräsentiert eine Entscheidung/Verzweigung
  - `id`: Eindeutige Choice-ID
  - `text`: Angezeigter Text der Option
  - `nextPageId`: Ziel-Seiten-ID
  - `description`: Optional detaillierte Beschreibung

- **`BookGraph`**: Repräsentiert das gesamte Buch als Graph
  - `pages`: Map von Seiten-IDs zu StoryPage-Objekten
  - `startPageId`: ID der Startseite
  - Methoden für Navigation (next, previous, getPage)

### 2. Data Layer (`lib/data/`)
Der Data Layer verwaltet Datenzugriff und -speicherung.

#### Repositories
- **`BookRepository`**: Interface für Datenzugriff
- **`MockBookRepository`**: Mock-Implementierung mit hardcoded Daten
  - Enthält 10 Seiten (page_1 bis page_10)
  - Seite 3 demonstriert Branching mit 3 Choices (A/B/C)
  - Simuliert Netzwerk-Delay für realistische UX

### 3. Features Layer (`lib/features/`)
Feature-spezifische Implementierungen, organisiert nach Funktionalität.

#### Reader Feature (`features/reader/`)

##### Providers (State Management mit Riverpod)
- **`book_provider.dart`**
  - `bookRepositoryProvider`: Stellt Repository bereit
  - `bookProvider`: Lädt das aktuelle Buch
  - `bookStateProvider`: Synchroner Zugriff auf Buch-State

- **`reader_state_provider.dart`**
  - `ReaderState`: State-Klasse für Reader-Screen
  - `ReaderStateNotifier`: Verwaltet Reader-State
  - Funktionen: TextScale, Zoom, FontFamily, Loading, Error

- **`navigation_provider.dart`**
  - `NavigationNotifier`: Navigationslogik
  - Methoden: getNextPage, getPreviousPage, getPageById
  - Progress-Tracking (current/total)

##### Presentation Layer
**Pages:**
- **`home_page.dart`**: Landing Page
  - Zeigt Buch-Info
  - Start-Button zur ersten Seite
  - Fortsetzen-Button (für zukünftige Features)

- **`reader_page.dart`**: Hauptleser-Screen
  - Zeigt aktuelle Seite
  - Navigation vor/zurück
  - Branching-Choices bei Verzweigungen
  - Settings-Sheet für Textanpassungen

**Widgets:**
- **`reader_app_bar.dart`**: Custom AppBar
  - Zeigt Kapitel-Titel
  - Progress-Indikator (X/10)
  - Linear Progress Bar
  - Settings-Button

- **`navigation_bar.dart`**: Bottom Navigation
  - Zurück/Weiter Buttons
  - Disabled state wenn keine Navigation möglich
  - Unterschiedliche Farben für bessere UX

- **`choice_card.dart`**: Branching-Choices
  - Card-Design für Choices
  - Text + optionale Beschreibung
  - ChoicesList für mehrere Optionen

### 4. Core Layer (`lib/core/`)
Gemeinsam genutzte Ressourcen und Utilities.

#### Theme (`core/theme/`)
- **`app_theme.dart`**: Material 3 Theme-Konfiguration
  - Light & Dark Theme
  - Vollständige Typography-Definition
  - Button-Styles (Elevated, Filled, Outlined)
  - Card-Styles mit Outline

#### Router (`core/router/`)
- **`app_router.dart`**: go_router Konfiguration
  - Route: `/` → HomePage
  - Route: `/reader?pageId=X` → ReaderPage
  - Deep-Link Support
  - Error-Handling
  - Extension für einfache Navigation

#### Constants (`core/constants/`)
- **`app_constants.dart`**: App-weite Konstanten
  - Animation-Dauern
  - Text-Scale Limits (0.8 - 2.0)
  - Zoom Limits (0.5 - 3.0)
  - Padding/Spacing Werte
  - Reader Max-Width (800px)

#### Widgets (`core/widgets/`)
- **`interactive_text_container.dart`**: Interaktiver Text-Container
  - AnimatedScale für Zoom
  - AnimatedDefaultTextStyle für Text-Anpassungen
  - Double-Tap für Zoom-Toggle
  - Vorbereitet für Pinch-to-Zoom
  - SelectableText für Textauswahl

## State Management

### Riverpod Provider-Hierarchie

```
ProviderScope (Root)
├── bookRepositoryProvider (Provider)
├── bookProvider (FutureProvider)
│   └── lädt BookGraph vom Repository
├── bookStateProvider (StateProvider)
│   └── synchroner Zugriff auf BookGraph
├── readerStateProvider (StateNotifierProvider.family)
│   └── verwaltet Reader-State pro Seite
└── navigationProvider (StateNotifierProvider)
    └── verwaltet Navigationslogik
```

## Datenfluss

### Seite laden
1. User navigiert zu `/reader?pageId=page_1`
2. `ReaderPage` wird mit `initialPageId` erstellt
3. `bookProvider` lädt BookGraph vom Repository
4. `ReaderPage` extrahiert aktuelle Seite aus BookGraph
5. UI wird mit Seiten-Daten gerendert

### Navigation (Linear)
1. User klickt "Weiter"
2. `navigationProvider.getNextPage()` wird aufgerufen
3. Nächste Seite wird aus BookGraph ermittelt
4. State wird mit neuer `pageId` aktualisiert
5. UI re-rendert mit neuer Seite

### Navigation (Branching)
1. User sieht Choices (z.B. bei Seite 3)
2. User wählt Choice (A/B/C)
3. `choice.nextPageId` wird extrahiert
4. Navigation zu dieser Seite
5. UI zeigt gewählten Pfad

### Text-Anpassungen
1. User öffnet Settings-Sheet
2. Slider ändert `textScale` Wert
3. `readerStateProvider.setTextScale()` wird aufgerufen
4. State wird aktualisiert
5. `InteractiveTextContainer` reagiert auf State-Änderung
6. `AnimatedDefaultTextStyle` animiert die Änderung

## UI/UX Features

### Material 3 Design
- Moderne Color Schemes (Light/Dark)
- Typography nach Material 3 Specs
- Rounded Corners (12px)
- Elevation mit Outlines statt Shadows
- Smooth Animations (200-500ms)

### Responsive Design
- Max-Width für Reader (800px)
- SafeArea für Notch/Home-Indicator
- ConstrainedBox für optimale Lesbarkeit
- ScrollPhysics: BouncingScrollPhysics

### Interaktionen
- **Double-Tap**: Zoom Toggle (1x ↔ 1.5x)
- **Slider**: TextScale Anpassung
- **Buttons**: Haptic Feedback (vorbereitet)
- **Animations**: Smooth Transitions

### Accessibility
- SelectableText für Textauswahl
- Semantics (vorbereitet)
- TextScale Support (0.8x - 2.0x)
- High Contrast (durch Material 3)

## Erweiterbarkeit

### Neue Features hinzufügen

#### 1. Neue Seite/Kapitel
```dart
// In MockBookRepository._createMockBook()
'page_11': const StoryPage(
  id: 'page_11',
  title: 'Kapitel 11',
  content: 'Inhalt...',
  displayOrder: 11,
),
```

#### 2. Neue Choice/Verzweigung
```dart
StoryPage(
  // ...
  choices: const [
    Choice(
      id: 'choice_x',
      text: 'Option X',
      nextPageId: 'page_y',
    ),
  ],
),
```

#### 3. Neue Reader-Einstellung
```dart
// In ReaderState
final String newSetting;

// In ReaderStateNotifier
void setNewSetting(String value) {
  state = state.copyWith(newSetting: value);
}
```

#### 4. Neue Route
```dart
// In app_router.dart
GoRoute(
  path: '/new-route',
  name: 'newRoute',
  builder: (context, state) => NewPage(),
),
```

### Zukünftige Features (vorbereitet)

- **Pinch-to-Zoom**: Gesture-Detector bereits in InteractiveTextContainer
- **Font-Family Switch**: State bereits in ReaderState
- **Lesezeichen**: State-Provider kann erweitert werden
- **Progress-Speicherung**: Repository-Interface kann erweitert werden
- **Bilder/Illustrationen**: StoryPage.content kann erweitert werden
- **Audio/Sound**: Neue Provider für Audio-Playback
- **Mehrere Bücher**: BookGraph-ID bereits vorhanden

## Testing-Strategie

### Unit Tests
- Domain Models (StoryPage, Choice, BookGraph)
- Navigation Logic (getNextPage, getPreviousPage)
- State Notifiers (ReaderStateNotifier)

### Widget Tests
- InteractiveTextContainer
- ChoiceCard, NavigationBar
- ReaderAppBar

### Integration Tests
- Navigation Flow (Home → Reader → Choices)
- Settings-Änderungen
- Error-Handling

## Performance-Optimierungen

### Aktuelle Optimierungen
- Riverpod für effizientes State Management
- const Constructors wo möglich
- Lazy Loading mit FutureProvider
- AnimationController Disposal

### Zukünftige Optimierungen
- Image Caching
- Text Pre-rendering
- Route Pre-loading
- State Persistence

## Deployment

### Build Commands
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Environment Variables
Keine Environment Variables erforderlich (aktuell).

## Abhängigkeiten

### Production
- `flutter_riverpod`: State Management
- `go_router`: Navigation
- `riverpod_annotation`: Code Generation

### Development
- `flutter_lints`: Linting
- `build_runner`: Code Generation
- `custom_lint`: Custom Linting
- `riverpod_lint`: Riverpod-spezifische Lints

## Konventionen

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `camelCase` mit `static const`
- Private: `_leadingUnderscore`

### Struktur
- Ein Widget pro Datei (außer kleine Helper-Widgets)
- Provider in separaten Dateien
- Gruppierung nach Feature, nicht nach Typ

### Kommentare
- Klassen-Dokumentation mit `///`
- Komplexe Logik mit `//` Inline-Kommentaren
- TODOs mit `// TODO: ...`

## Lizenz
MIT License


