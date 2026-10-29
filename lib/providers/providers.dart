import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/group_repo.dart';
import '../data/passenger_repo.dart';
import '../data/request_repo.dart';
import '../data/session_store.dart';
import '../data/trip_repo.dart';
import '../features/walkthrough/walkthrough_controller.dart';
import '../features/walkthrough/walkthrough_keys.dart';
import '../features/walkthrough/walkthrough_speech.dart';
import '../logic/matcher.dart';
import '../logic/optimizer.dart';
import '../logic/score.dart';
import '../models/passenger.dart';
import '../models/plan.dart';
import '../models/swap_request.dart';
import '../models/trip.dart';

// Repository Providers
final sessionStoreProvider = Provider<SessionStore>((ref) {
  throw UnimplementedError(
    'sessionStoreProvider must be overridden in ProviderScope',
  );
});

final walkthroughKeysProvider = Provider<WalkthroughKeys>((ref) {
  return WalkthroughKeys();
});

final walkthroughControllerProvider =
    StateNotifierProvider<WalkthroughController, WalkthroughState>((ref) {
      return WalkthroughController(ref.watch(sessionStoreProvider));
    });

final walkthroughSpeechProvider = ChangeNotifierProvider<WalkthroughSpeech>((
  ref,
) {
  final speech = WalkthroughSpeech(ref.watch(sessionStoreProvider));
  ref.onDispose(speech.dispose);
  return speech;
});

final tripRepoProvider = Provider<TripRepo>((ref) => TripRepo());
final passengerRepoProvider = Provider<PassengerRepo>((ref) => PassengerRepo());
final groupRepoProvider = Provider<GroupRepo>((ref) => GroupRepo());
final requestRepoProvider = Provider<RequestRepo>((ref) => RequestRepo());

// Session & Demo User
final currentPassengerIdProvider = StateProvider<String?>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return store.getPassengerId();
});

// Trip Provider
final tripProvider = FutureProvider<Trip>((ref) async {
  final repo = ref.watch(tripRepoProvider);
  return repo.getDemoTrip();
});

// Realtime Trip Passengers
final tripPassengersProvider = StreamProvider<List<Passenger>>((ref) async* {
  final trip = await ref.watch(tripProvider.future);
  yield* ref.watch(passengerRepoProvider).watchTripPassengers(trip.id);
});

// Derived Current Passenger
final currentPassengerProvider = Provider<Passenger?>((ref) {
  final currentId = ref.watch(currentPassengerIdProvider);
  if (currentId == null) return null;
  final passengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];
  try {
    return passengers.firstWhere((p) => p.id == currentId);
  } catch (_) {
    return null;
  }
});

// My Group Passengers
final myGroupProvider = Provider<List<Passenger>>((ref) {
  final me = ref.watch(currentPassengerProvider);
  if (me == null || me.groupId == null) return [];
  final passengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];
  return passengers.where((p) => p.groupId == me.groupId).toList();
});

// Group Seating Score
final groupScoreProvider = Provider<int>((ref) {
  final group = ref.watch(myGroupProvider);
  return groupScore(group);
});

// Requests Streams
final incomingRequestsProvider = StreamProvider<List<SwapRequest>>((ref) {
  final me = ref.watch(currentPassengerProvider);
  if (me == null) return const Stream.empty();
  final repo = ref.watch(requestRepoProvider);
  return repo.watchIncoming(me.id);
});

final outgoingRequestsProvider = StreamProvider<List<SwapRequest>>((ref) {
  final me = ref.watch(currentPassengerProvider);
  if (me == null) return const Stream.empty();
  final repo = ref.watch(requestRepoProvider);
  return repo.watchOutgoing(me.id);
});

// Preferences State
class SwapPrefs {
  final String? preferredBerth;
  final bool sameCoachOnly;
  final bool nearGroup;
  final bool onlyOpen;

  const SwapPrefs({
    this.preferredBerth,
    this.sameCoachOnly = false,
    this.nearGroup = false,
    this.onlyOpen = true,
  });

  SwapPrefs copyWith({
    String? Function()? preferredBerth,
    bool? sameCoachOnly,
    bool? nearGroup,
    bool? onlyOpen,
  }) {
    return SwapPrefs(
      preferredBerth: preferredBerth != null
          ? preferredBerth()
          : this.preferredBerth,
      sameCoachOnly: sameCoachOnly ?? this.sameCoachOnly,
      nearGroup: nearGroup ?? this.nearGroup,
      onlyOpen: onlyOpen ?? this.onlyOpen,
    );
  }
}

final swapPrefsProvider = StateProvider<SwapPrefs>((ref) => const SwapPrefs());

// Individual Matches
final matchesProvider = Provider<List<Match>>((ref) {
  final me = ref.watch(currentPassengerProvider);
  if (me == null) return [];
  final passengers = ref.watch(tripPassengersProvider).valueOrNull ?? [];
  final group = ref.watch(myGroupProvider);
  final prefs = ref.watch(swapPrefsProvider);

  return findMatches(
    me: me,
    all: passengers,
    group: group,
    preferredBerth: prefs.preferredBerth,
    sameCoachOnly: prefs.sameCoachOnly,
    nearGroup: prefs.nearGroup,
    onlyOpen: prefs.onlyOpen,
  );
});

// Plan Optimizer & Excluded Passengers
final excludedIdsProvider = StateProvider<Set<String>>((ref) => <String>{});

final planProvider = Provider<Plan?>((ref) {
  final group = ref.watch(myGroupProvider);
  if (group.length < 2) return null;
  final all = ref.watch(tripPassengersProvider).valueOrNull ?? [];
  final excluded = ref.watch(excludedIdsProvider);
  final availablePassengers = all
      .where((p) => !excluded.contains(p.id))
      .toList();
  return bestPlan(group: group, all: availablePassengers);
});

final activePlanIdProvider = StateProvider<String?>((ref) => null);

/// Asks the Requests screen to open a tab: 0 incoming, 3 rejected.
final requestsTabIndexProvider = StateProvider<int?>((ref) => null);

final activePlanRequestsProvider = StreamProvider<List<SwapRequest>>((ref) {
  final planId = ref.watch(activePlanIdProvider);
  if (planId == null) return const Stream.empty();
  final repo = ref.watch(requestRepoProvider);
  return repo.watchPlanRequests(planId);
});
