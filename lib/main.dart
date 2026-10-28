import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/passenger.dart';
import 'screens/coach_seat_map_screen.dart';
import 'screens/group_seating_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/requests_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const RailBuddyApp());
}

class RailBuddyApp extends StatelessWidget {
  const RailBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RailBuddy - Smart Group Seating',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationHolder(),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0; // 0: Home, 1: My Group, 2: Seat Map, 3: Requests, 4: Profile
  bool _showOnboarding = false;
  bool _isOptimized = false;
  double _cohesionScore = 20.0;

  late List<Passenger> _passengers;

  @override
  void initState() {
    super.initState();
    _resetPassengers();
  }

  void _resetPassengers() {
    _passengers = [
      Passenger(
        id: '1',
        name: 'Aman Sharma',
        isCurrentUser: true,
        coach: 'S1',
        seatNumber: 23,
        berthType: 'Middle Berth (MB)',
        cohesionLevel: CohesionLevel.sameCoach,
        avatarLetter: 'A',
      ),
      Passenger(
        id: '2',
        name: 'Bhavna Sharma',
        coach: 'S2',
        seatNumber: 41,
        berthType: 'Lower Berth (LB)',
        bay: 'Bay 7',
        pairedWith: 'Chetan',
        cohesionLevel: CohesionLevel.sameBay,
        statusNote: 'Paired w/ Chetan',
        avatarLetter: 'B',
      ),
      Passenger(
        id: '3',
        name: 'Chetan Sharma',
        coach: 'S2',
        seatNumber: 42,
        berthType: 'Middle Berth (MB)',
        bay: 'Bay 7',
        pairedWith: 'Bhavna',
        cohesionLevel: CohesionLevel.sameBay,
        statusNote: 'Paired w/ Bhavna',
        avatarLetter: 'C',
      ),
      Passenger(
        id: '4',
        name: 'Disha Sharma',
        coach: 'S3',
        seatNumber: 56,
        berthType: 'Side Lower Berth (SL)',
        cohesionLevel: CohesionLevel.otherCoach,
        statusNote: 'Isolated in S3',
        avatarLetter: 'D',
      ),
      Passenger(
        id: '5',
        name: 'Esha Sharma',
        coach: 'S4',
        seatNumber: 21,
        berthType: 'Upper Berth (UB)',
        cohesionLevel: CohesionLevel.otherCoach,
        statusNote: 'Isolated in S4',
        avatarLetter: 'E',
      ),
      Passenger(
        id: '6',
        name: 'Farhan Sharma',
        coach: 'S5',
        seatNumber: 37,
        berthType: 'Side Upper Berth (SU)',
        cohesionLevel: CohesionLevel.otherCoach,
        statusNote: 'Isolated in S5',
        avatarLetter: 'F',
      ),
    ];
  }

  void _optimizeGroup() {
    setState(() {
      _isOptimized = !_isOptimized;
      if (_isOptimized) {
        _cohesionScore = 88.0;
        _passengers = [
          Passenger(
            id: '1',
            name: 'Aman Sharma',
            isCurrentUser: true,
            coach: 'S2',
            seatNumber: 48,
            berthType: 'Side Upper Berth (SU)',
            bay: 'Bay 7',
            cohesionLevel: CohesionLevel.sameBay,
            statusNote: 'Bay 7 (Consolidated)',
            avatarLetter: 'A',
          ),
          Passenger(
            id: '2',
            name: 'Bhavna Sharma',
            coach: 'S2',
            seatNumber: 41,
            berthType: 'Lower Berth (LB)',
            bay: 'Bay 7',
            pairedWith: 'Chetan',
            cohesionLevel: CohesionLevel.sameBay,
            statusNote: 'Bay 7 (Consolidated)',
            avatarLetter: 'B',
          ),
          Passenger(
            id: '3',
            name: 'Chetan Sharma',
            coach: 'S2',
            seatNumber: 42,
            berthType: 'Middle Berth (MB)',
            bay: 'Bay 7',
            pairedWith: 'Bhavna',
            cohesionLevel: CohesionLevel.sameBay,
            statusNote: 'Bay 7 (Consolidated)',
            avatarLetter: 'C',
          ),
          Passenger(
            id: '4',
            name: 'Disha Sharma',
            coach: 'S2',
            seatNumber: 43,
            berthType: 'Upper Berth (UB)',
            bay: 'Bay 7',
            cohesionLevel: CohesionLevel.sameBay,
            statusNote: 'Bay 7 (Matched trade)',
            avatarLetter: 'D',
          ),
          Passenger(
            id: '5',
            name: 'Esha Sharma',
            coach: 'S2',
            seatNumber: 44,
            berthType: 'Upper Berth (UB)',
            bay: 'Bay 7',
            cohesionLevel: CohesionLevel.sameBay,
            statusNote: 'Bay 7 (Matched trade)',
            avatarLetter: 'E',
          ),
          Passenger(
            id: '6',
            name: 'Farhan Sharma',
            coach: 'S2',
            seatNumber: 47,
            berthType: 'Side Lower Berth (SL)',
            bay: 'Bay 7',
            cohesionLevel: CohesionLevel.sameBay,
            statusNote: 'Bay 7 (Consolidated)',
            avatarLetter: 'F',
          ),
        ];
      } else {
        _cohesionScore = 20.0;
        _resetPassengers();
      }
    });

    if (_isOptimized) {
      _showOptimizationCelebration();
    }
  }

  void _showOptimizationCelebration() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(26),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emeraldBorder, width: 2),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.emerald,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Optimal Family Reunion Found!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coach S2 Bay 7 accommodates all 6 members together. Group cohesion has skyrocketed from 20% to 88%!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCelebrationStat('20%', 'Initial', AppColors.rose),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.brandAccent, size: 18),
                    _buildCelebrationStat('88%', 'Reunited', AppColors.emerald),
                    Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildCelebrationStat('Bay 7', 'Coach S2', AppColors.brandNavy),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2); // Jump to seat map
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Explore Coach S2 Interactive Map →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCelebrationStat(String top, String bottom, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          top,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          bottom,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  void _showIndividualSwapDialog(Passenger p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.brandAccent,
                    child: Text(
                      p.avatarLetter,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swap Matches for ${p.name}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Current: Coach ${p.coach} · Seat ${p.seatNumber} (${p.berthType})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Available Fellow Passenger Matches in Coach S2:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildSwapOption(
                targetCoach: 'S2',
                targetSeat: '43',
                targetBerth: 'Upper Berth (UB)',
                passengerLabel: 'Priyanka M. (Open to swap for any lower berth)',
              ),
              const SizedBox(height: 8),
              _buildSwapOption(
                targetCoach: 'S2',
                targetSeat: '44',
                targetBerth: 'Upper Berth (UB)',
                passengerLabel: 'Amit S. (Open to swap for Coach S1)',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Explore Coach S2 Interactive Map',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwapOption({
    required String targetCoach,
    required String targetSeat,
    required String targetBerth,
    required String passengerLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: AppColors.brandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.brandAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach $targetCoach · Seat $targetSeat ($targetBerth)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  passengerLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _optimizeGroup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Select',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onFinish: () {
          setState(() {
            _showOnboarding = false;
          });
        },
      );
    }

    Widget currentScreen;
    String headerTitle;
    String? headerSubtitle;

    switch (_currentIndex) {
      case 0:
        headerTitle = 'RailBuddy';
        headerSubtitle = 'Home';
        currentScreen = HomeScreen(
          isOptimized: _isOptimized,
          onNavigateToGroup: () => setState(() => _currentIndex = 1),
          onNavigateToSeatMap: () => setState(() => _currentIndex = 2),
          onNavigateToRequests: () => setState(() => _currentIndex = 3),
          onNavigateToProfile: () => setState(() => _currentIndex = 4),
          onToggleOptimize: _optimizeGroup,
        );
        break;
      case 1:
        headerTitle = 'RailBuddy';
        headerSubtitle = 'My Group';
        currentScreen = GroupSeatingScreen(
          passengers: _passengers,
          cohesionScore: _cohesionScore,
          isOptimized: _isOptimized,
          onOptimizeGroup: _optimizeGroup,
          onSwapPassenger: _showIndividualSwapDialog,
          onOpenSeatMap: () => setState(() => _currentIndex = 2),
        );
        break;
      case 2:
        headerTitle = 'RailBuddy';
        headerSubtitle = 'Seat Map';
        currentScreen = CoachSeatMapScreen(
          onBack: () => setState(() => _currentIndex = 1),
          onConsolidateSuccess: () {
            setState(() {
              _isOptimized = true;
              _cohesionScore = 88.0;
            });
          },
        );
        break;
      case 3:
        headerTitle = 'RailBuddy';
        headerSubtitle = 'Swaps';
        currentScreen = const RequestsScreen();
        break;
      case 4:
      default:
        headerTitle = 'RailBuddy';
        headerSubtitle = 'Profile';
        currentScreen = ProfileScreen(
          onShowOnboarding: () => setState(() => _showOnboarding = true),
        );
        break;
    }

    final isHome = _currentIndex == 0;
    final isSeatMap = _currentIndex == 2;

    return Scaffold(
      backgroundColor: isHome ? AppColors.darkCharcoal : AppColors.scaffoldBg,
      body: SafeArea(
        top: !isHome,
        child: Column(
          children: [
            // Top App Bar
            if (!isHome && !isSeatMap)
              RailBuddyHeader(
                title: headerTitle,
                subtitle: headerSubtitle,
                onNotificationTap: () => setState(() => _currentIndex = 3),
                onProfileTap: () => setState(() => _currentIndex = 4),
              ),

            // Active Page Body
            Expanded(child: currentScreen),
          ],
        ),
      ),
      bottomNavigationBar: RailBuddyBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
