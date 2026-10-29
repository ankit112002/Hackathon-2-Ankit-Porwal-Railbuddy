import 'package:flutter/widgets.dart';

enum WalkthroughTargetId {
  homeTicket,
  homeModes,
  homeSwap,
  homeCta,
  bottomNav,
  groupFocus,
  requestsTabs,
  profileDemo,
}

class WalkthroughKeys {
  final Map<WalkthroughTargetId, GlobalKey> _keys = {
    for (final id in WalkthroughTargetId.values) id: GlobalKey(),
  };

  GlobalKey keyFor(WalkthroughTargetId id) => _keys[id]!;
}
