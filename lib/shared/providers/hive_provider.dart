import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/hive_service.dart';

part 'hive_provider.g.dart';

@Riverpod(keepAlive: true)
Future<HiveService> hiveService(Ref ref) async {
  final service = HiveService();
  await service.init();
  return service;
}
