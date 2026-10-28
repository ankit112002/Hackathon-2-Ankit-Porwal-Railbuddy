import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';
import 'demo_data.dart';
import 'supabase_client.dart';

class GroupRepo {
  final SupabaseClient? _client;
  static final List<Group> _localGroups = [DemoData.group];

  GroupRepo([SupabaseClient? client])
      : _client = client ?? supabaseClientOrNull;

  Future<Group?> getByJoinCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (_client != null) {
      final response = await _client
          .from('groups')
          .select()
          .eq('join_code', clean)
          .maybeSingle();
      if (response == null) return null;
      return Group.fromMap(response);
    }

    try {
      return _localGroups.firstWhere((g) => g.joinCode == clean);
    } catch (_) {
      return null;
    }
  }

  Future<Group?> getById(String id) async {
    if (_client != null) {
      final response =
          await _client.from('groups').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return Group.fromMap(response);
    }

    try {
      return _localGroups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final buffer = StringBuffer('RAIL-');
    for (var i = 0; i < 4; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  Future<Group> createGroup({
    required String tripId,
    required String name,
  }) async {
    if (_client != null) {
      for (var attempt = 0; attempt < 5; attempt++) {
        final code = _generateJoinCode();
        try {
          final res = await _client
              .from('groups')
              .insert({
                'trip_id': tripId,
                'name': name.trim(),
                'join_code': code,
              })
              .select()
              .single();
          return Group.fromMap(res);
        } on PostgrestException catch (e) {
          if (e.code == '23505' && attempt < 4) continue;
          rethrow;
        }
      }
    }

    final localGroup = Group(
      id: 'group-${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      name: name.trim(),
      joinCode: _generateJoinCode(),
    );
    _localGroups.add(localGroup);
    return localGroup;
  }
}
