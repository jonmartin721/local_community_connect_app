import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/hive_provider.dart';

part 'events_provider.g.dart';

@riverpod
class EventsNotifier extends _$EventsNotifier {
  @override
  Future<List<Event>> build() async {
    final hive = await ref.watch(hiveServiceProvider.future);
    return hive.getAllEvents()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Event> filterByCategory(List<Event> events, String? category) {
    if (category == null) return events;
    return events.where((e) => e.category == category).toList();
  }
}

@riverpod
List<String> eventCategories(Ref ref) {
  return ['Community', 'Government', 'Arts', 'Sports', 'Health', 'Education'];
}

@riverpod
Future<Event?> eventById(Ref ref, String id) async {
  final hive = await ref.watch(hiveServiceProvider.future);
  return hive.getEvent(id);
}
