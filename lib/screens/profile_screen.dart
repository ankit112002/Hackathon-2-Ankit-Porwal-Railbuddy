import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onShowOnboarding;

  const ProfileScreen({super.key, required this.onShowOnboarding});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _openToSwaps = true;
  bool _discreetNotifications = true;
  bool _autoGroupOptimization = true;
  bool _preferLowerBerthsForSeniors = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Card
          _buildProfileHeaderCard(),

          const SizedBox(height: 18),

          // Travel Impact Stats Grid
          _buildTravelStatsGrid(),

          const SizedBox(height: 22),

          // Active Booking & Family Roster Section
          _buildActiveBookingSection(),

          const SizedBox(height: 22),

          // Preferences
          Text(
            'SWAP & PRIVACY PREFERENCES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.sync_rounded,
                  title: 'Open to Peer Swaps',
                  subtitle: 'Allow travelers in adjacent bogies to send swap requests',
                  value: _openToSwaps,
                  onChanged: (val) => setState(() => _openToSwaps = val),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSwitchTile(
                  icon: Icons.notifications_off_outlined,
                  title: 'Discreet Smartphone Alerts',
                  subtitle: 'Silent in-app notifications without loud cabin negotiation',
                  value: _discreetNotifications,
                  onChanged: (val) => setState(() => _discreetNotifications = val),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSwitchTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Smart AI Auto-Consolidation',
                  subtitle: 'Automatically recommend full-bay trades for Sharma Family',
                  value: _autoGroupOptimization,
                  onChanged: (val) => setState(() => _autoGroupOptimization = val),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSwitchTile(
                  icon: Icons.elderly_rounded,
                  title: 'Prioritize Lower Berths for Elders',
                  subtitle: 'Never exchange lower berths for seniors unless requested',
                  value: _preferLowerBerthsForSeniors,
                  onChanged: (val) => setState(() => _preferLowerBerthsForSeniors = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // App & Guidelines
          Text(
            'APP & RAILWAY GUIDELINES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.brandLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_outlined, color: AppColors.brandAccent, size: 20),
                  ),
                  title: Text(
                    'Revisit Onboarding Guide',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'See how smart bay clustering and peer swaps work',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                  onTap: widget.onShowOnboarding,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: AppColors.emerald, size: 20),
                  ),
                  title: Text(
                    'Indian Railways Swap Policy & TTE Rules',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Voluntary mutual agreements among ticketed passengers',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Railway Swap Guidelines',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '• Mutual seat exchanges between confirmed ticket holders are permissible with mutual consent.\n• Both passengers should be present in their coaches.\n• You may display your RailBuddy digital exchange confirmation card to the Travelling Ticket Examiner (TTE) during chart inspection.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AppColors.textBody,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandNavy,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Understood'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.darkCharcoal, AppColors.forestMint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'AS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mintAccent,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.mintAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.darkCharcoal, size: 11),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Aman Sharma',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, size: 16, color: AppColors.forestMint),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '+91 98200 12345 · irctc_aman',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mintSurfaceLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'IRCTC Verified',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestMint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '4.9 ★ Trust',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatTile('6', 'Travelers', 'Sharma Group', AppColors.brandAccent)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatTile('14', 'Swaps', 'Completed', AppColors.emerald)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatTile('88%', 'Peak Cohesion', 'Bay 7 S2', const Color(0xFF7C3AED))),
      ],
    );
  }

  Widget _buildStatTile(String value, String label, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LINKED PNR & FAMILY TRIP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Confirmed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '12951 · Mumbai Rajdhani Express',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'PNR 8472910482 · NDLS to MMCT · 6 Berths',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.brandAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.brandAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
