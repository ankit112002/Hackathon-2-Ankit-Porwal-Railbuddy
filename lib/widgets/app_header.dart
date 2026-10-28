import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Interactive tactile spring-scale button that provides responsive press feedback.
class BouncingScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final BorderRadius? borderRadius;

  const BouncingScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.92,
    this.borderRadius,
  });

  @override
  State<BouncingScaleButton> createState() => _BouncingScaleButtonState();
}

class _BouncingScaleButtonState extends State<BouncingScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// An animated radar pulse beacon with an expanding ripple wave around a vibrant emerald dot.
class PulsingBeaconDot extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  final double maxRippleSize;

  const PulsingBeaconDot({
    super.key,
    this.dotColor = AppColors.emerald,
    this.dotSize = 7.0,
    this.maxRippleSize = 18.0,
  });

  @override
  State<PulsingBeaconDot> createState() => _PulsingBeaconDotState();
}

class _PulsingBeaconDotState extends State<PulsingBeaconDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.maxRippleSize,
      height: widget.maxRippleSize,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final progress = _animation.value;
          final rippleSize = widget.dotSize +
              (widget.maxRippleSize - widget.dotSize) * progress;
          final rippleOpacity = (1.0 - progress).clamp(0.0, 0.7);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Expanding ripple wave
              Container(
                width: rippleSize,
                height: rippleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dotColor.withValues(alpha: rippleOpacity),
                  border: Border.all(
                    color: widget.dotColor.withValues(alpha: rippleOpacity * 0.9),
                    width: 1.0,
                  ),
                ),
              ),
              // Center solid glowing core
              Container(
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: widget.dotColor.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Notification Bell with periodic gentle wiggle chime micro-animation and unread badge.
class WigglingBellButton extends StatefulWidget {
  final VoidCallback? onTap;
  final int count;

  const WigglingBellButton({
    super.key,
    this.onTap,
    this.count = 4,
  });

  @override
  State<WigglingBellButton> createState() => _WigglingBellButtonState();
}

class _WigglingBellButtonState extends State<WigglingBellButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Sequence: 0ms..600ms wiggle, 600ms..2800ms rest
    _angleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.22)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.22, end: 0.22)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.22, end: -0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.12)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.12, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 128,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerWiggle() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BouncingScaleButton(
      onTap: _triggerWiggle,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.cardBorderSubtle, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _angleAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _angleAnimation.value,
                  alignment: Alignment.topCenter,
                  child: child,
                );
              },
              child: const Icon(
                Icons.notifications_outlined,
                size: 21,
                color: AppColors.textDark,
              ),
            ),

            // Red Badge with Count or Dot
            if (widget.count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: AppColors.rose,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rose.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 9,
                    minHeight: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Friendly waving hand emoji animation for the greeting row.
class AnimatedWavingHand extends StatefulWidget {
  final double size;

  const AnimatedWavingHand({super.key, this.size = 20});

  @override
  State<AnimatedWavingHand> createState() => _AnimatedWavingHandState();
}

class _AnimatedWavingHandState extends State<AnimatedWavingHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Friendly 3-wave cycle followed by a pause
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.28)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.28, end: -0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.25)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 16,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.25, end: -0.10)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.10, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 130,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.forward(from: 0.0),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            alignment: const Alignment(0.4, 0.8),
            child: Text('👋', style: TextStyle(fontSize: widget.size)),
          );
        },
      ),
    );
  }
}

/// Redesigned ultra-premium RailBuddy app header.
/// Features glassmorphism, animated train brand mark, live telemetry radar beacon,
/// dynamic screen transition badges, and tactile spring action buttons.
class RailBuddyHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  const RailBuddyHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final activeTab = subtitle ?? title;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 11.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Back Button OR Animated Brand Train Mark
          if (showBack) ...[
            BouncingScaleButton(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.cardBorderSubtle, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            BouncingScaleButton(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF141D1B).withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle ambient inner highlight
                    Positioned(
                      top: 2,
                      left: 4,
                      child: Container(
                        width: 22,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.directions_transit_rounded,
                      color: AppColors.mintAccent,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Center: Title, Live Telemetry Tag & Route Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'RailBuddy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Contextual Dynamic Status Badge with smooth AnimatedSwitcher
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: _buildContextBadge(activeTab),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Subtitle Row with contextual detail & icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildSubtitleRow(activeTab),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Right: Wiggling Notification Bell Action
          WigglingBellButton(
            onTap: onNotificationTap,
            count: notificationCount,
          ),

          const SizedBox(width: 8),

          // Right: User Profile Avatar with Online Status
          BouncingScaleButton(
            onTap: onProfileTap,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDBEAFE),
                      width: 2,
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'AS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds context-sensitive pill badge alongside "RailBuddy"
  Widget _buildContextBadge(String activeTab) {
    if (activeTab == 'Home' || activeTab == 'Journey') {
      return Container(
        key: const ValueKey('home_badge'),
        padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PulsingBeaconDot(
              dotColor: AppColors.emerald,
              dotSize: 6,
              maxRippleSize: 13,
            ),
            SizedBox(width: 4),
            Text(
              'LIVE TRIP',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.emerald,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    } else if (activeTab == 'My Group') {
      return Container(
        key: const ValueKey('group_badge'),
        padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
        ),
        child: const Text(
          '6 IN GROUP',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4F46E5),
            letterSpacing: 0.4,
          ),
        ),
      );
    } else if (activeTab == 'Swaps' || activeTab == 'Requests') {
      return Container(
        key: const ValueKey('swaps_badge'),
        padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1),
        ),
        child: const Text(
          '4 READY',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFD97706),
            letterSpacing: 0.4,
          ),
        ),
      );
    } else {
      return Container(
        key: ValueKey(activeTab),
        padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
        decoration: BoxDecoration(
          color: AppColors.brandLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
        ),
        child: Text(
          activeTab.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppColors.brandAccent,
            letterSpacing: 0.4,
          ),
        ),
      );
    }
  }

  /// Builds context-sensitive subtitle line with iconography
  Widget _buildSubtitleRow(String activeTab) {
    String text;
    IconData icon;
    Color iconColor;

    if (activeTab == 'Home' || activeTab == 'Journey') {
      text = 'NDLS ➔ MMCT · 12951 Rajdhani';
      icon = Icons.train_outlined;
      iconColor = AppColors.brandAccent;
    } else if (activeTab == 'My Group') {
      text = 'Sharma Family · Bay 7 Assistance';
      icon = Icons.groups_rounded;
      iconColor = const Color(0xFF4F46E5);
    } else if (activeTab == 'Swaps' || activeTab == 'Requests') {
      text = 'Active Peer Exchange Radar';
      icon = Icons.swap_horiz_rounded;
      iconColor = const Color(0xFFD97706);
    } else if (activeTab == 'Coach Seat Map' || activeTab == 'Seat Map') {
      text = 'Coach S2 · Interactive Bay Map';
      icon = Icons.airline_seat_recline_extra_rounded;
      iconColor = AppColors.brandAccent;
    } else {
      text = 'Aman Sharma · PNR 8472910482';
      icon = Icons.verified_user_outlined;
      iconColor = AppColors.emerald;
    }

    return Row(
      key: ValueKey('sub_$activeTab'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
