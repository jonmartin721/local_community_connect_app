# Community Connect

A beautifully designed Flutter app for discovering local events, news, and community resources. Built as a portfolio project demonstrating modern Flutter architecture and clean design principles.

## Features

- **Events Discovery** - Browse upcoming community events with category filtering
- **Local News** - Stay informed with community announcements and updates
- **Resource Directory** - Find local services, government offices, and community organizations
- **Favorites** - Save events, news, and resources for quick access
- **Search** - Find content across all categories
- **Dark Mode** - Full dark theme support
- **Offline-First** - Data persists locally with Hive

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.7+ |
| **State Management** | Riverpod 3.0 (with code generation) |
| **Navigation** | go_router |
| **Local Storage** | Hive |
| **Architecture** | Feature-first, Clean Architecture principles |

## Architecture

```
lib/
├── app/                    # App-level configuration
│   ├── theme/              # Colors, typography, Material 3 theme
│   └── router.dart         # Navigation configuration
├── features/               # Feature modules
│   ├── events/             # Events feature
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Feature-specific widgets
│   │   └── providers/      # Riverpod state management
│   ├── news/               # News feature
│   ├── resources/          # Resources feature
│   ├── favorites/          # Favorites feature
│   ├── search/             # Search feature
│   └── onboarding/         # Onboarding flow
├── shared/                 # Shared code
│   ├── models/             # Data models + Hive adapters
│   ├── data/               # Data layer (Hive service, sample data)
│   ├── providers/          # Shared providers
│   └── widgets/            # Shared widgets
└── main.dart               # App entry point
```

## Design

The app features a warm, welcoming design palette:

- **Primary**: Terracotta (#E07A5F) - warm, approachable
- **Secondary**: Sage (#81B29A) - natural, calming
- **Tertiary**: Gold (#F2CC8F) - friendly, optimistic

Typography uses **Fraunces** (display) and **Nunito Sans** (body) for a distinctive, readable experience.

## Getting Started

### Prerequisites

- Flutter SDK 3.7 or higher
- Dart 3.0 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/local_community_connect_app.git
   cd local_community_connect_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (Riverpod providers)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Highlights

### State Management (Riverpod 3.0)

Providers use code generation for type safety:

```dart
@riverpod
class EventsNotifier extends _$EventsNotifier {
  @override
  Future<List<Event>> build() async {
    final hive = await ref.watch(hiveServiceProvider.future);
    return hive.getAllEvents()..sort((a, b) => a.date.compareTo(b.date));
  }
}
```

### Local Persistence (Hive)

Manually-written TypeAdapters for clean serialization:

```dart
class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;
  // Read/write implementation
}
```

### Navigation (go_router)

Declarative routing with ShellRoute for persistent bottom nav:

```dart
ShellRoute(
  builder: (context, state, child) => BottomNavShell(child: child),
  routes: [
    GoRoute(path: '/events', ...),
    GoRoute(path: '/news', ...),
  ],
)
```

## What This Demonstrates

- **Feature-first architecture** for scalable Flutter apps
- **Riverpod 3.0** state management with code generation
- **go_router** for declarative navigation
- **Hive** for efficient local storage
- **Material 3** theming with custom design systems
- **Clean separation** between UI, state, and data layers

## Future Enhancements

- [ ] Backend integration (Firebase/Supabase)
- [ ] Push notifications for events
- [ ] Map integration for locations
- [ ] Social sharing

## License

MIT License - feel free to use as a learning resource.

---

Built with Flutter
