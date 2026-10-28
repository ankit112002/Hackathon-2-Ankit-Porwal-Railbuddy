import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/passenger.dart';
import '../models/plan.dart';
import '../models/swap_request.dart';
import 'passenger_repo.dart';
import 'supabase_client.dart';

class RequestRepo {
  final SupabaseClient? _client;
  static final List<SwapRequest> _localRequests = [];
  static final StreamController<List<SwapRequest>> _localStreamController =
      StreamController<List<SwapRequest>>.broadcast();

  RequestRepo([SupabaseClient? client])
      : _client = client ?? supabaseClientOrNull;

  static String generateUuid() {
    final rnd = Random();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Stream<List<SwapRequest>> watchIncoming(String passengerId) async* {
    if (_client != null) {
      yield* _client
          .from('swap_requests')
          .stream(primaryKey: ['id'])
          .eq('target_id', passengerId)
          .order('created_at', ascending: false)
          .map((rows) => rows.map((r) => SwapRequest.fromMap(r)).toList());
      return;
    }

    yield _localRequests.where((r) => r.targetId == passengerId).toList();
    yield* _localStreamController.stream
        .map((list) => list.where((r) => r.targetId == passengerId).toList());
  }

  Stream<List<SwapRequest>> watchOutgoing(String passengerId) async* {
    if (_client != null) {
      yield* _client
          .from('swap_requests')
          .stream(primaryKey: ['id'])
          .eq('requester_id', passengerId)
          .order('created_at', ascending: false)
          .map((rows) => rows.map((r) => SwapRequest.fromMap(r)).toList());
      return;
    }

    yield _localRequests.where((r) => r.requesterId == passengerId).toList();
    yield* _localStreamController.stream
        .map((list) => list.where((r) => r.requesterId == passengerId).toList());
  }

  Stream<List<SwapRequest>> watchPlanRequests(String planId) async* {
    if (_client != null) {
      yield* _client
          .from('swap_requests')
          .stream(primaryKey: ['id'])
          .eq('plan_id', planId)
          .map((rows) => rows.map((r) => SwapRequest.fromMap(r)).toList());
      return;
    }

    yield _localRequests.where((r) => r.planId == planId).toList();
    yield* _localStreamController.stream
        .map((list) => list.where((r) => r.planId == planId).toList());
  }

  Future<String> sendRequest({
    required Passenger from,
    required Passenger to,
    String? planId,
    String? message,
  }) async {
    if (_client != null) {
      final existing = await _client
          .from('swap_requests')
          .select('id')
          .eq('requester_id', from.id)
          .eq('target_id', to.id)
          .eq('status', 'pending')
          .maybeSingle();
      if (existing != null) {
        throw Exception(
          'A pending swap request already exists for this passenger.',
        );
      }

      final res = await _client
          .from('swap_requests')
          .insert({
            'trip_id': from.tripId,
            'requester_id': from.id,
            'target_id': to.id,
            'requester_seat': from.seatKey,
            'target_seat': to.seatKey,
            'plan_id': planId,
            'message': message,
            'status': 'pending',
          })
          .select('id')
          .single();
      return res['id'] as String;
    }

    final existingLocal = _localRequests.any((r) =>
        r.requesterId == from.id &&
        r.targetId == to.id &&
        r.status == SwapRequestStatus.pending);
    if (existingLocal) {
      throw Exception(
        'A pending swap request already exists for this passenger.',
      );
    }

    final newId = generateUuid();
    _localRequests.insert(
      0,
      SwapRequest(
        id: newId,
        tripId: from.tripId,
        requesterId: from.id,
        targetId: to.id,
        requesterSeat: from.seatKey,
        targetSeat: to.seatKey,
        planId: planId,
        message: message,
        status: SwapRequestStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    _localStreamController.add(List<SwapRequest>.unmodifiable(_localRequests));
    return newId;
  }

  /// Sends one request per swap and returns the shared plan id.
  Future<({String planId, List<String> requestIds})> sendPlanRequests(
    Plan plan,
    String tripId,
  ) async {
    final planId = generateUuid();
    final ids = <String>[];

    for (final pair in plan.swaps) {
      final reqId = await sendRequest(
        from: pair.member,
        to: pair.volunteer,
        planId: planId,
        message: 'Group seating plan: move to ${pair.volunteer.seatKey}',
      );
      ids.add(reqId);
    }

    return (planId: planId, requestIds: ids);
  }

  Future<String> accept(String id) async {
    if (_client != null) {
      final res = await _client.rpc('accept_swap', params: {'req_id': id});
      return res.toString();
    }

    final idx = _localRequests.indexWhere((r) => r.id == id);
    if (idx == -1) return 'not_pending';
    final req = _localRequests[idx];
    final pRepo = PassengerRepo();
    final pA = await pRepo.getById(req.requesterId);
    final pB = await pRepo.getById(req.targetId);
    if (pA.seatKey != req.requesterSeat || pB.seatKey != req.targetSeat) {
      _replaceLocal(idx, req, SwapRequestStatus.invalid);
      return 'invalid';
    }
    PassengerRepo.localSwapSeats(pA, pB);
    _replaceLocal(idx, req, SwapRequestStatus.accepted);
    return 'accepted';
  }

  Future<void> reject(String id) async {
    if (_client != null) {
      await _client.rpc('reject_swap', params: {'req_id': id});
      return;
    }
    _setLocalStatus(id, SwapRequestStatus.rejected);
  }

  Future<void> cancel(String id) async {
    if (_client != null) {
      await _client.rpc('cancel_swap', params: {'req_id': id});
      return;
    }
    _setLocalStatus(id, SwapRequestStatus.cancelled);
  }

  void _setLocalStatus(String id, SwapRequestStatus status) {
    final idx = _localRequests.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _replaceLocal(idx, _localRequests[idx], status);
  }

  void _replaceLocal(int idx, SwapRequest req, SwapRequestStatus status) {
    _localRequests[idx] = SwapRequest(
      id: req.id,
      tripId: req.tripId,
      requesterId: req.requesterId,
      targetId: req.targetId,
      requesterSeat: req.requesterSeat,
      targetSeat: req.targetSeat,
      planId: req.planId,
      message: req.message,
      status: status,
      createdAt: req.createdAt,
      respondedAt: DateTime.now(),
    );
    _localStreamController.add(List<SwapRequest>.unmodifiable(_localRequests));
  }
}
