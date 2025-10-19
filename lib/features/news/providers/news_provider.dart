import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/hive_provider.dart';

part 'news_provider.g.dart';

@riverpod
class NewsNotifier extends _$NewsNotifier {
  @override
  Future<List<NewsItem>> build() async {
    final hive = await ref.watch(hiveServiceProvider.future);
    return hive.getAllNews()
      ..sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
  }
}

@riverpod
Future<NewsItem?> newsById(Ref ref, String id) async {
  final hive = await ref.watch(hiveServiceProvider.future);
  return hive.getNewsItem(id);
}
