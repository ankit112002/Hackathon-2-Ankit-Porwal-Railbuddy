import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/session_store.dart';
import 'walkthrough_steps.dart';

class WalkthroughState {
  final bool active;
  final int stepIndex;

  const WalkthroughState({this.active = false, this.stepIndex = 0});

  WalkthroughState copyWith({bool? active, int? stepIndex}) {
    return WalkthroughState(
      active: active ?? this.active,
      stepIndex: stepIndex ?? this.stepIndex,
    );
  }
}

class WalkthroughController extends StateNotifier<WalkthroughState> {
  WalkthroughController(this._store) : super(const WalkthroughState());

  final SessionStore _store;
  bool _completing = false;

  void startIfNeeded() {
    if (state.active || _completing) return;
    if (_store.isWalkthroughCompleted()) return;
    final passengerId = _store.getPassengerId();
    if (passengerId == null || passengerId.isEmpty) return;
    state = const WalkthroughState(active: true, stepIndex: 0);
  }

  void back() {
    if (!state.active || state.stepIndex == 0) return;
    state = state.copyWith(stepIndex: state.stepIndex - 1);
  }

  Future<void> next() async {
    if (!state.active || _completing) return;
    if (state.stepIndex >= walkthroughSteps.length - 1) {
      await _complete();
      return;
    }
    state = state.copyWith(stepIndex: state.stepIndex + 1);
  }

  Future<void> skip() => _complete();

  Future<void> replay() async {
    await _store.setWalkthroughCompleted(false);
    state = const WalkthroughState(active: true, stepIndex: 0);
  }

  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    await _store.setWalkthroughCompleted(true);
    state = const WalkthroughState();
    _completing = false;
  }
}
