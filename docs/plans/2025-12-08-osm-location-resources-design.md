# OpenStreetMap Location-Based Resources

Design for auto-populating the Resources section with real data from OpenStreetMap based on user location.

## Overview

**Goal:** Transform Resources from hardcoded sample data to real local businesses and services fetched from OpenStreetMap when user enters their city or zip code.

**Scope:**
- Resources: Real data from OpenStreetMap
- News: Stays as sample data (CORS blocks most RSS feeds from web client)
- Events: Stays as sample data (no free CORS-friendly event API exists)

**Constraints:**
- Free, no API keys required
- Client-side only (no backend)
- Web-primary (must be CORS-friendly)

## Data Sources

### OpenStreetMap Overpass API

Query endpoint: `https://overpass-api.de/api/interpreter`

No authentication required. CORS-friendly. Returns JSON with place names, addresses, coordinates, and metadata.

**Category Mapping:**

| App Category | OSM Tags |
|--------------|----------|
| Education | `amenity=library`, `amenity=school`, `amenity=college` |
| Recreation | `amenity=community_centre`, `leisure=sports_centre`, `leisure=swimming_pool` |
| Government | `office=government`, `amenity=townhall`, `amenity=post_office` |
| Emergency Services | `amenity=police`, `amenity=fire_station`, `amenity=hospital` |
| Parks | `leisure=park`, `leisure=nature_reserve` |
| Health | `amenity=clinic`, `amenity=pharmacy`, `amenity=doctors` |

### Nominatim Geocoding

Endpoint: `https://nominatim.openstreetmap.org/search`

Converts city name or zip code to coordinates. No authentication required. CORS-friendly.

## Data Mapping

OSM data maps to existing `LocalResource` model:

| LocalResource field | OSM source | Fallback |
|---------------------|------------|----------|
| `id` | `"osm-" + element.id` | - |
| `name` | `tags["name"]` | Humanized amenity/leisure tag |
| `category` | Derived from OSM tag type | - |
| `address` | `tags["addr:street"] + tags["addr:housenumber"]` | null |
| `phoneNumber` | `tags["phone"]` or `tags["contact:phone"]` | null |
| `websiteUrl` | `tags["website"]` or `tags["contact:website"]` | null |
| `description` | `tags["description"]` | null |

ID prefix `osm-` distinguishes fetched resources from any manually-added ones.

## User Flow

### Location Setup Screen

Entry points:
1. Onboarding (new screen after "Get Started", skippable)
2. Settings ("Change Location" option)

Flow:
1. User enters city name or zip code
2. Nominatim geocodes to coordinates
3. If multiple results, user picks from top 3-5 options
4. App stores location and fetches resources from Overpass
5. Resources screen shows real local data

### Screen States

- **Empty**: Text field and search button
- **Loading**: Spinner while geocoding
- **Results**: Radio list of location options
- **Fetching**: Progress indicator ("Finding local resources...")
- **Done**: Navigate to main app or back to settings

Skip behavior: Uses sample data (current behavior). User can set location later.

## Persistence

### Hive Storage

New fields in settings box:
- `locationName`: String (e.g., "Portland, Oregon")
- `locationLat`: double
- `locationLon`: double
- `isUsingRealData`: bool
- `lastResourceFetch`: DateTime

### Refresh Strategy

- On location change: Clear and re-fetch resources
- Manual refresh: Button in settings
- No auto-refresh: User controls when

### Reset Option

"Reset to sample data" in settings:
1. Clears location
2. Clears fetched resources
3. Re-seeds with sample data

## Error Handling

| Error | Message | Recovery |
|-------|---------|----------|
| Nominatim no results | "Location not found. Try a different search." | Edit and retry |
| Nominatim network error | "Couldn't connect. Check your internet." | Retry button |
| Overpass timeout | "Search timed out..." | Auto-retry smaller query |
| Overpass no results | "No resources found nearby." | Empty state, try different location |
| Overpass network error | "Couldn't fetch resources." | Retry or skip |

Graceful degradation: App always offers path forward (retry, skip to sample data, try later).

## New Components

### LocationService

Handles:
- Geocoding via Nominatim
- Overpass queries
- Mapping OSM data to LocalResource

### Location Setup Screen

New screen at `lib/features/settings/screens/location_setup_screen.dart`

### HiveService Extensions

New getters/setters for location and data source tracking.

## Files to Create/Modify

**Create:**
- `lib/shared/services/location_service.dart`
- `lib/features/settings/screens/location_setup_screen.dart`
- `lib/features/settings/providers/location_provider.dart`

**Modify:**
- `lib/shared/data/hive_service.dart` (add location fields)
- `lib/app/router.dart` (add location setup route)
- `lib/features/settings/screens/settings_screen.dart` (add location option)
- `lib/features/onboarding/screens/onboarding_screen.dart` (optional: add location step)
