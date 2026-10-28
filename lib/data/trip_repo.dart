import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';
import 'demo_data.dart';
import 'supabase_client.dart';

class TripRepo {
  final SupabaseClient? _client;

  TripRepo([SupabaseClient? client])
      : _client = client ?? supabaseClientOrNull;

  Future<Trip> getDemoTrip() async {
    if (_client == null) return DemoData.trip;

    final response = await _client
        .from('trips')
        .select()
        .order('journey_date', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      throw Exception(
        'No demo trip found. Run supabase/seed.sql in the Supabase SQL editor.',
      );
    }
    return Trip.fromMap(response);
  }

  Future<void> updateTrip(Trip trip) async {
    if (_client == null) return;
    await _client.from('trips').update(trip.toMap()).eq('id', trip.id);
  }
}
