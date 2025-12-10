# Web/Desktop Usability Design

## Overview

Improve the app's usability on web and desktop by adding responsive navigation, constraining content widths, and fixing button accessibility issues.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Navigation approach | Adaptive shell (single widget) | Simpler than separate shells, navigation logic stays in one place |
| Breakpoint | 800px | Matches existing responsive grid breakpoints |
| NavigationRail style | Icons + labels, no extended mode | 5 short labels fit well in standard rail |
| Detail screen max-width | 700px | Optimal line length for reading |
| List screen max-width | 1400px | Matches existing main screens |
| Button max-width | 320px | Prevents awkward full-width buttons on desktop |
| Grid columns | 1 mobile, 2 desktop | Simpler than 3-column, sufficient for smaller lists |
| Design system fixes | Only in modified files | Keeps change cohesive, avoids scope creep |

## Changes

### 1. Adaptive Navigation Shell

**File:** `lib/shared/widgets/bottom_nav_shell.dart`

Detect screen width and render either `NavigationBar` (< 800px) or `NavigationRail` (>= 800px).

```dart
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isWide = screenWidth >= 800;

  if (isWide) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex(context),
            onDestinationSelected: (index) => _onTap(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event),
                label: Text('Events'),
              ),
              // ... other destinations
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  // Current bottom nav implementation
  return Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(...),
  );
}
```

### 2. Detail Screen Max-Width (700px)

**Files:**
- `lib/features/events/screens/event_detail_screen.dart`
- `lib/features/news/screens/news_detail_screen.dart`
- `lib/features/resources/screens/resource_detail_screen.dart`

Wrap scrollable content in `Center` + `ConstrainedBox`:

```dart
body: Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 700),
    child: CustomScrollView(...),
  ),
),
```

### 3. Button Fixes

#### 3a. Full-Width Button Constraint (320px)

**Files:**
- `lib/features/profile/screens/profile_screen.dart`
- `lib/features/onboarding/screens/onboarding_screen.dart`

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton(...),
    ),
  ),
),
```

#### 3b. FavoriteButton Touch Target (48px minimum)

**File:** `lib/shared/widgets/favorite_button.dart`

```dart
// Increase padding to meet 48px minimum
padding: EdgeInsets.all(compact ? 14 : 13),
// compact: 14 + 14 + 20 icon = 48px
// normal: 13 + 13 + 22 icon = 48px
```

#### 3c. FavoriteButton Accessibility

**File:** `lib/shared/widgets/favorite_button.dart`

```dart
Icon(
  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
  semanticLabel: isFavorite ? 'Remove from favorites' : 'Add to favorites',
  ...
)
```

### 4. Responsive Grids for List Screens

**Files:**
- `lib/features/favorites/screens/favorites_screen.dart`
- `lib/features/search/screens/search_screen.dart`

Add width detection and 1400px max-width:

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isWide = screenWidth > 800;

return Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1400),
    child: isWide
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 2.5, // Adjust per card type
            ),
            ...
          )
        : ListView.builder(...),
  ),
);
```

### 5. Profile & Location Setup Max-Width

**ProfileScreen:** 1400px (list-like content)

**LocationSetupScreen:** 700px (form-focused)

Same `Center` + `ConstrainedBox` pattern as other screens.

### 6. Design System Fixes (AppSpacing)

Replace magic numbers in all modified files:

| Magic Number | AppSpacing Constant |
|--------------|---------------------|
| 4 | `AppSpacing.xs` |
| 8 | `AppSpacing.sm` |
| 12 | `AppSpacing.md` |
| 16 | `AppSpacing.lg` |
| 20 | `AppSpacing.xl` |
| 24 | `AppSpacing.xxl` |
| 32 | `AppSpacing.xxxl` |

**EdgeInsets mappings:**
- `EdgeInsets.all(16)` -> `AppSpacing.paddingLg`
- `EdgeInsets.all(20)` -> `AppSpacing.paddingXl`

**SizedBox mappings:**
- `SizedBox(height: 16)` -> `AppSpacing.verticalLg`
- `SizedBox(width: 8)` -> `AppSpacing.horizontalSm`

## Files Modified

| File | Changes |
|------|---------|
| `bottom_nav_shell.dart` | Adaptive NavigationBar/NavigationRail |
| `event_detail_screen.dart` | 700px max-width, AppSpacing |
| `news_detail_screen.dart` | 700px max-width, AppSpacing |
| `resource_detail_screen.dart` | 700px max-width, AppSpacing |
| `favorites_screen.dart` | 1400px max-width, responsive grid, AppSpacing |
| `search_screen.dart` | 1400px max-width, responsive grid, AppSpacing |
| `profile_screen.dart` | 1400px max-width, button constraint, AppSpacing |
| `location_setup_screen.dart` | 700px max-width, AppSpacing |
| `onboarding_screen.dart` | Button constraint |
| `favorite_button.dart` | Touch target 48px, semanticLabel |
| `settings_screen.dart` | AppSpacing for hardcoded padding |

## Testing

After implementation:
1. Run `flutter analyze` - no new warnings
2. Run `flutter test` - all tests pass
3. Manual testing at various widths: 400px, 800px, 1200px, 1600px
4. Verify NavigationRail appears at 800px+
5. Verify content doesn't stretch beyond max-widths
6. Verify buttons are max 320px on wide screens
7. Test screen reader announces favorite button state
