import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'walkthrough_keys.dart';

class WalkthroughTarget extends ConsumerWidget {
  final WalkthroughTargetId id;
  final Widget child;

  const WalkthroughTarget({super.key, required this.id, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(walkthroughKeysProvider).keyFor(id);
    return KeyedSubtree(key: key, child: child);
  }
}
