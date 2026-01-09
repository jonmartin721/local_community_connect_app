# Community Connect

A Flutter app for discovering local events, news, and community resources. I built this as a portfolio project to demonstrate feature-first architecture, Riverpod 3.0, and offline-first data with Hive.

## Features

- **Events** — Browse upcoming events with category filtering
- **News** — Community announcements and updates
- **Resources** — Local services, government offices, organizations
- **Profile** — User preferences with notifications and privacy settings
- **Favorites** — Save anything for quick access
- **Search** — Find content across all categories
- **Dark Mode** — Full theme support
- **Offline-First** — Everything persists locally

## Tech Stack

| | |
|---|---|
| **Framework** | Flutter 3.7+ |
| **State** | Riverpod 3.0 with codegen |
| **Navigation** | go_router |
| **Storage** | Hive |
| **Testing** | 96 unit and widget tests |

## Quick Start

```bash
git clone https://github.com/jonmartin721/local_community_connect_app.git
cd local_community_connect_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Architecture

```
lib/
├── app/                    # Theme + router
├── features/               # Feature modules
│   ├── events/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── providers/
│   ├── news/
│   ├── resources/
│   ├── favorites/
│   ├── search/
│   ├── profile/
│   └── onboarding/
└── shared/                 # Models, data layer, shared widgets
```

Each feature follows the same pattern: `screens/`, `providers/`, and optionally `widgets/`.

## Code Examples

### Riverpod with Code Generation

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

### Manual Hive TypeAdapters

I wrote the TypeAdapters by hand rather than using code generation—gives more control over serialization:

```dart
class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    return Event(
      id: reader.read(),
      title: reader.read(),
      // ...
    );
  }
}
```

### go_router with Shell

```dart
ShellRoute(
  builder: (context, state, child) => BottomNavShell(child: child),
  routes: [
    GoRoute(path: '/events', builder: (_, __) => const EventsScreen()),
    GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),
    // ...
  ],
)
```

## Design

The color palette is intentionally warm:

- **Terracotta** `#E07A5F` — primary actions
- **Sage** `#81B29A` — secondary elements
- **Gold** `#F2CC8F` — accents

Typography: Fraunces for headings, Nunito Sans for body text.

## Testing

```bash
flutter test
```

96 tests covering:
- Provider logic (events, news, resources, search, theme)
- HiveService data layer
- Widget rendering and navigation
- Edge cases and error states

## License

MIT — use it however you want.
