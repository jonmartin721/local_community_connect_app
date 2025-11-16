import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hive_provider.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final hiveAsync = ref.watch(hiveServiceProvider);
    return hiveAsync.when(
      data: (hive) => hive.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );
  }

  Future<void> toggle() async {
    final hive = await ref.read(hiveServiceProvider.future);
    final isDark = state == ThemeMode.dark;
    await hive.setDarkMode(!isDark);
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}
