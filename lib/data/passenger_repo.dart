import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/passenger.dart';
import 'demo_data.dart';
import 'supabase_client.dart';

class PassengerRepo {
  final SupabaseClient? _client;
  static final List<Passenger> _localPassengers =
      DemoData.createInitialPassengers();
  static final StreamController<List<Passenger>> _localStreamController =
      StreamController<List<Passenger>>.broadcast();

  PassengerRepo([SupabaseClient? client])
      : _client = client ?? supabaseClientOrNull;

  Stream<List<Passenger>> watchTripPassengers(String tripId) async* {
    if (_client == null) {
      yield List<Passenger>.unmodifiable(_localPassengers);
      yield* _localStreamController.stream;
      return;
    }

    yield await getTripPassengers(tripId);
    yield* _client
        .from('passengers')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .map((rows) => rows.map((r) => Passenger.fromMap(r)).toList());
  }

  Future<List<Passenger>> getTripPassengers(String tripId) async {
    if (_client == null) {
      return List<Passenger>.unmodifiable(_localPassengers);
    }
    final response =
        await _client.from('passengers').select().eq('trip_id', tripId);
    return (response as List)
        .map((r) => Passenger.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<Passenger> getById(String id) async {
    if (_client == null) {
      return _localPassengers.firstWhere((p) => p.id == id);
    }
    final response =
        await _client.from('passengers').select().eq('id', id).single();
    return Passenger.fromMap(response);
  }

  Future<void> updateWillingToSwap(String id, bool value) async {
    if (_client != null) {
      await _client
          .from('passengers')
          .update({'willing_to_swap': value})
          .eq('id', id);
      return;
    }

    final idx = _localPassengers.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _localPassengers[idx] =
        _localPassengers[idx].copyWith(willingToSwap: value);
    _localStreamController.add(List<Passenger>.unmodifiable(_localPassengers));
  }

  Future<void> updateSeat(
    String id, {
    required String coach,
    required int seatNo,
    String? name,
  }) async {
    if (_client != null) {
      final data = <String, dynamic>{
        'coach': coach,
        'seat_no': seatNo,
      };
      if (name != null && name.trim().isNotEmpty) {
        data['name'] = name.trim();
      }
      await _client.from('passengers').update(data).eq('id', id);
      return;
    }

    final idx = _localPassengers.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _localPassengers[idx] = _localPassengers[idx].copyWith(
      coach: coach,
      seatNo: seatNo,
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : _localPassengers[idx].name,
    );
    _localStreamController.add(List<Passenger>.unmodifiable(_localPassengers));
  }

  Future<void> assignToGroup(String passengerId, String? groupId) async {
    if (_client != null) {
      await _client
          .from('passengers')
          .update({'group_id': groupId})
          .eq('id', passengerId);
      return;
    }

    final idx = _localPassengers.indexWhere((p) => p.id == passengerId);
    if (idx == -1) return;
    _localPassengers[idx] = _localPassengers[idx].copyWith(groupId: groupId);
    _localStreamController.add(List<Passenger>.unmodifiable(_localPassengers));
  }

  // Internal helper to perform local seat swap
  static void localSwapSeats(Passenger a, Passenger b) {
    final idxA = _localPassengers.indexWhere((p) => p.id == a.id);
    final idxB = _localPassengers.indexWhere((p) => p.id == b.id);
    if (idxA != -1 && idxB != -1) {
      final oldACoach = _localPassengers[idxA].coach;
      final oldASeat = _localPassengers[idxA].seatNo;

      _localPassengers[idxA] = _localPassengers[idxA].copyWith(
        coach: _localPassengers[idxB].coach,
        seatNo: _localPassengers[idxB].seatNo,
      );
      _localPassengers[idxB] = _localPassengers[idxB].copyWith(
        coach: oldACoach,
        seatNo: oldASeat,
      );
      _localStreamController.add(List<Passenger>.unmodifiable(_localPassengers));
    }
  }
}
