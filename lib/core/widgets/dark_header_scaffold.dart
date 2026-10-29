import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DarkHeaderScaffold extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget? bottomBar;
  final PreferredSizeWidget? appBar;
  final bool scrollable;
  final String? headerImageAsset;
  final Alignment headerImageAlignment;

  /// When true, the photo fades out toward the left so titles stay clear
  /// and the artwork reads on the right, like the home greeting.
  final bool fadeHeaderImageRight;

  const DarkHeaderScaffold({
    super.key,
    required this.header,
    required this.body,
    this.bottomBar,
    this.appBar,
    this.scrollable = true,
    this.headerImageAsset,
    this.headerImageAlignment = Alignment.centerRight,
    this.fadeHeaderImageRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: appBar,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Dark Header Section
            SizedBox(
              width: double.infinity,
              child: Stack(
              children: [
                if (headerImageAsset != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            headerImageAsset!,
                            fit: BoxFit.cover,
                            alignment: headerImageAlignment,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: fadeHeaderImageRight
                                  ? const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF0F1115),
                                        Color(0xF20F1115),
                                        Color(0x8C0F1115),
                                        Color(0x330F1115),
                                      ],
                                      stops: [0.0, 0.32, 0.58, 1.0],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0x990F1115),
                                        Color(0xD60F1115),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                header,
              ],
            ),
            ),

            // Overlapping Cream Sheet
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  child: scrollable
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 24,
                            bottom: 100,
                          ),
                          child: body,
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: body,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: bottomBar != null
          ? Container(
              color: AppColors.cream,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SafeArea(
                top: false,
                child: bottomBar!,
              ),
            )
          : null,
    );
  }
}
