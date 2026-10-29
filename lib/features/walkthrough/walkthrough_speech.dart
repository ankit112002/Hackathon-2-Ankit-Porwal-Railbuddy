import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/session_store.dart';
import 'walkthrough_steps.dart';

class WalkthroughSpeech extends ChangeNotifier {
  WalkthroughSpeech(this._store) : _muted = _store.isWalkthroughVoiceMuted();

  final SessionStore _store;
  final FlutterTts _tts = FlutterTts();

  bool _muted;
  bool _ready = false;
  int? _spokenStep;
  int _generation = 0;
  Future<void> _pending = Future<void>.value();

  bool get muted => _muted;

  Future<void> speakStep(int index, {bool force = false}) async {
    if (_muted) return;
    if (index < 0 || index >= walkthroughSteps.length) return;
    if (!force && _spokenStep == index) return;

    final generation = ++_generation;
    _spokenStep = index;
    final step = walkthroughSteps[index];
    final line = '${step.title}. ${step.body}';

    _enqueue(() async {
      try {
        await _ensureReady();
        if (generation != _generation || _muted) return;
        await _halt();
        if (generation != _generation || _muted) return;
        await _tts.speak(line);
      } catch (_) {
        // The spotlight still works when this device has no English voice.
      }
    });
  }

  Future<void> stop() async {
    _generation++;
    _spokenStep = null;
    _enqueue(_halt);
  }

  void _enqueue(Future<void> Function() action) {
    _pending = _pending.then((_) => action()).catchError((_) {});
  }

  Future<void> setMuted(bool value, {int? resumeIndex}) async {
    if (_muted != value) {
      _muted = value;
      await _store.setWalkthroughVoiceMuted(value);
      notifyListeners();
    }
    if (value) {
      await stop();
      return;
    }
    if (resumeIndex != null) {
      await speakStep(resumeIndex, force: true);
    }
  }

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    final selected = await _tts.setLanguage('en-US');
    if (selected == 0 || selected == false) {
      await _tts.setLanguage('en');
    }
    _ready = true;
  }

  Future<void> _halt() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _generation++;
    _tts.stop();
    super.dispose();
  }
}
