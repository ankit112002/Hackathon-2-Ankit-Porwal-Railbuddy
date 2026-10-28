import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/group.dart';
import '../../providers/providers.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final TextEditingController _codeController = TextEditingController();
  Group? _previewGroup;
  bool _isChecking = false;
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.length < 5) {
      setState(() {
        _previewGroup = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() => _isChecking = true);
    try {
      final grp = await ref.read(groupRepoProvider).getByJoinCode(clean);
      setState(() {
        _previewGroup = grp;
        _errorMessage = grp == null ? 'No group found with this join code.' : null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _joinGroup() async {
    final me = ref.read(currentPassengerProvider);
    if (me == null || _previewGroup == null) return;

    setState(() => _isJoining = true);
    try {
      await ref
          .read(passengerRepoProvider)
          .assignToGroup(me.id, _previewGroup!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined "${_previewGroup!.name}"!'),
          backgroundColor: AppColors.accepted,
        ),
      );
      context.go('/group');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join: ${e.toString()}'),
          backgroundColor: AppColors.rejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text(
          'Join Travel Group',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Group Join Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ask the group creator for their 9-character code (e.g. RAIL-7X92).',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'RAIL-XXXX',
                prefixIcon: const Icon(Icons.vpn_key_rounded),
                fillColor: AppColors.white,
                suffixIcon: _isChecking
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onChanged: _checkCode,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.rejected,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Group Preview Card
            if (_previewGroup != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.mintPressed, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mint.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.mint.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _previewGroup!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                'Code: ${_previewGroup!.joinCode}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accepted,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tap below to join this group and start arranging your seats together.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Join Group',
            isLoading: _isJoining,
            onPressed: _previewGroup != null ? _joinGroup : null,
          ),
        ),
      ),
    );
  }
}
