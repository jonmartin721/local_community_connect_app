import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/hive_provider.dart';

part 'resources_provider.g.dart';

@riverpod
class ResourcesNotifier extends _$ResourcesNotifier {
  @override
  Future<List<LocalResource>> build() async {
    final hive = await ref.watch(hiveServiceProvider.future);
    return hive.getAllResources()..sort((a, b) => a.name.compareTo(b.name));
  }

  Map<String, List<LocalResource>> groupByCategory(List<LocalResource> resources) {
    final grouped = <String, List<LocalResource>>{};
    for (final resource in resources) {
      grouped.putIfAbsent(resource.category, () => []).add(resource);
    }
    return grouped;
  }
}

@riverpod
Future<LocalResource?> resourceById(Ref ref, String id) async {
  final hive = await ref.watch(hiveServiceProvider.future);
  return hive.getResource(id);
}
