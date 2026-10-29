import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../providers/providers.dart';
import 'walkthrough_controller.dart';
import 'walkthrough_speech.dart';
import 'walkthrough_steps.dart';

class WalkthroughOverlay extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const WalkthroughOverlay({super.key, required this.navigationShell});

  @override
  ConsumerState<WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends ConsumerState<WalkthroughOverlay> {
  Rect? _hole;
  int? _ensuredStep;
  bool _scheduled = false;
  int _attempts = 0;
  int _switchAttempts = 0;
  late final WalkthroughSpeech _speech;
  late final ProviderSubscription<WalkthroughState> _tourSub;

  @override
  void initState() {
    super.initState();
    _speech = ref.read(walkthroughSpeechProvider);
    _tourSub = ref.listenManual<WalkthroughState>(
      walkthroughControllerProvider,
      _onTourChanged,
    );
    _schedule();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tour = ref.read(walkthroughControllerProvider);
      if (!tour.active) return;
      _speech.speakStep(tour.stepIndex);
    });
  }

  @override
  void dispose() {
    _tourSub.close();
    _speech.stop();
    super.dispose();
  }

  void _onTourChanged(WalkthroughState? prev, WalkthroughState next) {
    if (!mounted) return;
    if (!next.active) {
      _speech.stop();
      return;
    }
    if (prev?.stepIndex != next.stepIndex) {
      _speech.speakStep(next.stepIndex);
    }
    if (prev?.stepIndex == next.stepIndex && prev?.active == next.active) {
      return;
    }
    _ensuredStep = null;
    _attempts = 0;
    _switchAttempts = 0;
    _schedule();
    if (_hole != null) setState(() => _hole = null);
  }

  @override
  void didUpdateWidget(covariant WalkthroughOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _schedule();
    }
  }

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _prepareTarget();
    });
  }

  Future<void> _prepareTarget() async {
    if (!mounted) return;
    final tour = ref.read(walkthroughControllerProvider);
    if (!tour.active) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    final step = walkthroughSteps[tour.stepIndex];
    if (widget.navigationShell.currentIndex != step.tabIndex) {
      _switchAttempts += 1;
      if (_switchAttempts > 8) return;
      widget.navigationShell.goBranch(step.tabIndex);
      _schedule();
      return;
    }
    _switchAttempts = 0;

    final key = ref.read(walkthroughKeysProvider).keyFor(step.target);
    final targetContext = key.currentContext;
    final box = targetContext?.findRenderObject();
    if (targetContext == null ||
        box is! RenderBox ||
        !box.attached ||
        !box.hasSize) {
      final passenger = ref.read(currentPassengerProvider);
      if (passenger != null) _attempts += 1;
      if (passenger == null || _attempts < 120) _schedule();
      return;
    }

    if (_ensuredStep != tour.stepIndex) {
      final stepIndex = tour.stepIndex;
      _ensuredStep = stepIndex;
      _attempts = 0;
      if (Scrollable.maybeOf(targetContext) != null) {
        try {
          await Scrollable.ensureVisible(
            targetContext,
            alignment: 0.3,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      final latest = ref.read(walkthroughControllerProvider);
      if (!latest.active || latest.stepIndex != stepIndex) return;
      _schedule();
      return;
    }

    _publishHole(box);
  }

  double _clamp(double value, double min, double max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _publishHole(RenderBox box) {
    final overlayBox = context.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.hasSize) {
      _schedule();
      return;
    }
    final origin = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final inflated = (origin & box.size).inflate(8);
    final bounds = Offset.zero & overlayBox.size;
    final next = Rect.fromLTRB(
      _clamp(inflated.left, 8, bounds.width - 8),
      _clamp(inflated.top, 8, bounds.height - 8),
      _clamp(inflated.right, 8, bounds.width - 8),
      _clamp(inflated.bottom, 8, bounds.height - 8),
    );
    if (next.width < 8 || next.height < 8) return;
    if (_hole == next) return;
    setState(() => _hole = next);
  }

  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(walkthroughControllerProvider);
    final step = walkthroughSteps[tour.stepIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = _cardTop(constraints.maxHeight);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: CustomPaint(
                  painter: _HoleScrimPainter(hole: _hole),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: top,
              child: _WalkthroughCard(
                index: tour.stepIndex,
                total: walkthroughSteps.length,
                title: step.title,
                body: step.body,
              ),
            ),
          ],
        );
      },
    );
  }

  double _cardTop(double height) {
    const cardEstimate = 268.0;
    const margin = 16.0;
    final maxTop = height - cardEstimate - 12;
    final hole = _hole;
    double top;
    if (hole == null || hole.height > height * 0.65) {
      top = height - cardEstimate - margin;
    } else if (height - hole.bottom >= cardEstimate + margin) {
      top = hole.bottom + margin;
    } else if (hole.top >= cardEstimate + margin) {
      top = hole.top - cardEstimate - margin;
    } else {
      top = height - cardEstimate - margin;
    }
    if (top < 12) return 12;
    if (maxTop < 12) return 12;
    if (top > maxTop) return maxTop;
    return top;
  }
}

class _WalkthroughCard extends ConsumerWidget {
  final int index;
  final int total;
  final String title;
  final String body;

  const _WalkthroughCard({
    required this.index,
    required this.total,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(walkthroughControllerProvider.notifier);
    final speech = ref.watch(walkthroughSpeechProvider);
    final isFirst = index == 0;
    final isLast = index == total - 1;

    return Material(
      color: AppColors.cream,
      elevation: 8,
      shadowColor: AppColors.ink.withOpacity(0.28),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${index + 1} of $total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mintPressed,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: speech.muted ? 'Turn sound on' : 'Mute walkthrough',
                  onPressed: () {
                    speech.setMuted(!speech.muted, resumeIndex: index);
                  },
                  icon: Icon(
                    speech.muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: AppColors.ink,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    controller.skip();
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                if (!isFirst)
                  TextButton(
                    onPressed: controller.back,
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.ink,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    controller.next();
                  },
                  child: Text(
                    isLast ? 'Done' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoleScrimPainter extends CustomPainter {
  final Rect? hole;

  const _HoleScrimPainter({required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRect(Offset.zero & size);
    if (hole != null && hole!.width > 0 && hole!.height > 0) {
      path.addRRect(RRect.fromRectAndRadius(hole!, const Radius.circular(20)));
      path.fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(path, Paint()..color = const Color(0xC00F1115));
    if (hole != null && hole!.width > 0 && hole!.height > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(hole!, const Radius.circular(20)),
        Paint()
          ..color = AppColors.mint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HoleScrimPainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}
