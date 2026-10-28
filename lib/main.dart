import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/env.dart';
import 'data/session_store.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if keys are provided via --dart-define
  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  } else {
    debugPrint(
      'Notice: Running without SUPABASE_URL / SUPABASE_ANON_KEY dart-defines. '
      'Run with: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }

  // Initialize Local Session Store
  final sessionStore = await SessionStore.create();

  runApp(
    ProviderScope(
      overrides: [
        sessionStoreProvider.overrideWithValue(sessionStore),
      ],
      child: const RailBuddyApp(),
    ),
  );
}
