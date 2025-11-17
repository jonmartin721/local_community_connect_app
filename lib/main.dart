import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/router.dart';
import 'shared/data/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final router = createRouter(showOnboarding: !hiveService.hasSeenOnboarding);

  runApp(
    ProviderScope(
      child: CommunityConnectApp(router: router),
    ),
  );
}
