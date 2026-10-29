import 'walkthrough_keys.dart';

class WalkthroughStep {
  final WalkthroughTargetId target;
  final int tabIndex;
  final String title;
  final String body;

  const WalkthroughStep({
    required this.target,
    required this.tabIndex,
    required this.title,
    required this.body,
  });
}

const walkthroughSteps = <WalkthroughStep>[
  WalkthroughStep(
    target: WalkthroughTargetId.homeTicket,
    tabIndex: 0,
    title: 'Your journey',
    body:
        'This card shows your train, the stations, and the berth you are sitting in.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.homeModes,
    tabIndex: 0,
    title: 'Three ways to sit together',
    body:
        'Group Seating keeps your party together. Single Swap finds one exchange. Coach Map shows the berths.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.homeSwap,
    tabIndex: 0,
    title: 'Stay visible',
    body:
        'Leave this on so other passengers can ask you to swap. Turn it off to hide from suggestions.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.homeCta,
    tabIndex: 0,
    title: 'Start with your group',
    body:
        'Create or join a group, or open the plan that brings the people you are already with into one bay.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.bottomNav,
    tabIndex: 0,
    title: 'Four places',
    body:
        'Home, My Group, Requests, and Profile. The rest of this tour visits each one.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.groupFocus,
    tabIndex: 1,
    title: 'Your group',
    body:
        'See how close your party is to sitting together, or create a group if you are travelling solo.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.requestsTabs,
    tabIndex: 2,
    title: 'Consent lives here',
    body:
        'Incoming requests and the ones you sent. A swap happens only when both passengers agree.',
  ),
  WalkthroughStep(
    target: WalkthroughTargetId.profileDemo,
    tabIndex: 3,
    title: 'Try another passenger',
    body:
        'This demo lets you act as someone else on the train and see their seat, group, and requests.',
  ),
];
