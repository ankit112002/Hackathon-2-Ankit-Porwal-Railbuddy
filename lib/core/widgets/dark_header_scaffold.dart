import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DarkHeaderScaffold extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget? bottomBar;
  final PreferredSizeWidget? appBar;
  final bool scrollable;

  const DarkHeaderScaffold({
    super.key,
    required this.header,
    required this.body,
    this.bottomBar,
    this.appBar,
    this.scrollable = true,
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
            header,

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
