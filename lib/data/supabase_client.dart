import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient? get supabaseClientOrNull {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

bool get isSupabaseConfigured => supabaseClientOrNull != null;
