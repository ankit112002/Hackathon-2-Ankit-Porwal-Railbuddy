import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'providers/providers.dart';

class RailBuddyApp extends ConsumerWidget {
  const RailBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tripPassengersProvider, (previous, next) {
      final passengers = next.valueOrNull;
      if (passengers == null || passengers.isEmpty) return;
      final id = ref.read(currentPassengerIdProvider);
      if (id == null || id.isEmpty) return;
      if (passengers.any((p) => p.id == id)) return;
      ref.read(currentPassengerIdProvider.notifier).state = null;
      ref.read(sessionStoreProvider).clear();
      ref.read(routerProvider).go('/select-passenger');
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RailBuddy - Smart Group Seating',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
