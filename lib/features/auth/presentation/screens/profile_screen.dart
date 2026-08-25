import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/app_button.dart';
import 'package:prepgraph/core/widgets/error_state.dart';
import 'package:prepgraph/core/widgets/skeleton_loader.dart';
import 'package:prepgraph/features/auth/domain/entities/exam.dart';
import 'package:prepgraph/features/auth/domain/entities/learner_profile.dart';
import 'package:prepgraph/features/auth/domain/entities/user.dart';
import 'package:prepgraph/features/auth/presentation/providers/auth_providers.dart';

/// Profile Screen (S10.1/S10.2)
/// Identity display + inline editing + logout, built on the existing
/// ProfileRepository/AuthNotifier architecture (no new providers).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

/// Preset avatar colors, persisted locally as 'avatar:' + key via the
/// existing ProfileRepository.uploadAvatar (no real backend or file/photo
/// picker exists in this project, so the "avatar" is a local color choice
/// rather than an uploaded image).
const Map<String, Color> _avatarPalette = {
  'ink': AppColors.ink900,
  'sage': AppColors.sage500,
  'marigold': AppColors.marigold500,
  'azure': AppColors.azure500,
  'rose': AppColors.rose500,
  'graphite': AppColors.graphite700,
};

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  User? _user;
  List<Exam> _exams = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _errorMessage;

  late final TextEditingController _nameController;
  String? _selectedExamId;
  DateTime? _targetDate;
  int? _dailyStudyHours;
  PreparationLevel? _preparationLevel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Not signed in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final examsResult = await ref.read(profileRepositoryProvider).getExams();
    final profileResult = await ref.read(profileRepositoryProvider).getProfile(userId: userId);

    if (!mounted) return;

    examsResult.fold((_) {}, (exams) => _exams = exams);

    profileResult.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (user) {
        setState(() {
          _isLoading = false;
          _user = user;
          _resetEditFields(user);
        });
      },
    );
  }

  void _resetEditFields(User user) {
    _nameController.text = user.name;
    _selectedExamId = user.examId;
    _targetDate = user.targetDate;
    _dailyStudyHours = user.dailyStudyHours;
    _preparationLevel = user.preparationLevel == null
        ? null
        : PreparationLevel.values.firstWhere(
            (l) => l.name == user.preparationLevel,
            orElse: () => PreparationLevel.beginner,
          );
  }

  void _handleEnterEditMode() {
    if (_user != null) _resetEditFields(_user!);
    setState(() {
      _isEditing = true;
      _errorMessage = null;
    });
  }

  void _handleCancelEdit() {
    if (_user != null) _resetEditFields(_user!);
    setState(() {
      _isEditing = false;
      _errorMessage = null;
    });
  }

  Future<void> _handleSaveProfile() async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = await ref.read(profileRepositoryProvider).updateProfile(
          userId: userId,
          name: name,
          examId: _selectedExamId,
          targetDate: _targetDate,
          dailyStudyHours: _dailyStudyHours,
          preparationLevel: _preparationLevel?.name,
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        // Preserve the entered form values on failure so the user doesn't
        // have to retype anything to retry (per the Profile screen spec).
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (updatedUser) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
          _user = updatedUser;
        });
        ref.read(authProvider.notifier).restoreSession(updatedUser);
      },
    );
  }

  Future<void> _handlePickAvatar() async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    final selectedKey = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AvatarPickerSheet(),
    );
    if (selectedKey == null) return;

    final result = await ref.read(profileRepositoryProvider).uploadAvatar(
          userId: userId,
          filePath: 'avatar:$selectedKey',
        );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() => _errorMessage = failure.message),
      (avatarUrl) {
        if (_user != null) {
          setState(() => _user = _user!.copyWith(avatarUrl: avatarUrl));
        }
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Your progress is saved and will be here when you return.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out', style: TextStyle(color: AppColors.ink900)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final refreshToken = await ref.read(authLocalDataSourceProvider).getRefreshToken();
    await ref.read(authProvider.notifier).logout(refreshToken: refreshToken ?? '');

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          if (!_isLoading && _user != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _handleEnterEditMode,
              tooltip: 'Edit Profile',
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }
    if (_user == null) {
      return ErrorStates.network(
        onRetry: _loadProfile,
        contextMessage: _errorMessage ?? "We couldn't load your profile",
      );
    }

    final user = _user!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(user),
          const SizedBox(height: AppConstants.spaceLg),
          if (_errorMessage != null) ...[
            _buildErrorBanner(),
            const SizedBox(height: AppConstants.spaceMd),
          ],
          _isEditing ? _buildEditForm() : _buildInfoList(user),
          const SizedBox(height: AppConstants.spaceXl),
          AppSecondaryButton(
            label: 'Log out',
            onPressed: _handleLogout,
          ),
          const SizedBox(height: AppConstants.spaceLg),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      children: const [
        SkeletonCard(height: 140),
        SizedBox(height: AppConstants.spaceMd),
        SkeletonCard(height: 220),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.rose500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.rose500),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.rose500, size: 20),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.ink900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(User user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handlePickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _avatarColor(user.avatarUrl),
                  child: Text(
                    _initials(user.name),
                    style: GoogleFonts.fraunces(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightOnPrimary,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.paper50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightOutline),
                    ),
                    child: Icon(Icons.edit, size: 14, color: AppColors.ink900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            user.name,
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.school_outlined, 'Exam', _examName(user.examId)),
          _buildDivider(),
          _buildInfoTile(
            Icons.calendar_today_outlined,
            'Target Date',
            _formatDate(user.targetDate),
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.schedule_outlined,
            'Daily Study Hours',
            user.dailyStudyHours != null ? '${user.dailyStudyHours} hrs/day' : 'Not set',
          ),
          _buildDivider(),
          _buildInfoTile(
            Icons.trending_up_outlined,
            'Preparation Level',
            _preparationLevelName(user.preparationLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.graphite700),
          const SizedBox(width: AppConstants.spaceSm),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.lightOutlineVariant);
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          TextField(
            enabled: false,
            controller: TextEditingController(text: _user?.email ?? ''),
            decoration: const InputDecoration(
              labelText: 'Email',
              helperText: 'Email cannot be changed',
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          DropdownButtonFormField<String>(
            initialValue: _selectedExamId,
            decoration: const InputDecoration(labelText: 'Exam'),
            items: _exams
                .map((exam) => DropdownMenuItem(value: exam.id, child: Text(exam.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedExamId = value),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildTargetDatePicker(),
          const SizedBox(height: AppConstants.spaceMd),
          _buildStudyHoursSlider(),
          const SizedBox(height: AppConstants.spaceMd),
          _buildPreparationLevelPicker(),
          const SizedBox(height: AppConstants.spaceLg),
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Cancel',
                  onPressed: _handleCancelEdit,
                  enabled: !_isSaving,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: AppButton(
                  label: 'Save',
                  onPressed: _handleSaveProfile,
                  isLoading: _isSaving,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDatePicker() {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.graphite700),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Text(
            'Target Date: ${_formatDate(_targetDate)}',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.ink900,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 90)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) {
              setState(() => _targetDate = picked);
            }
          },
          child: const Text('Change'),
        ),
      ],
    );
  }

  Widget _buildStudyHoursSlider() {
    final hours = _dailyStudyHours ?? 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Study Hours: $hours hrs',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.ink900,
          ),
        ),
        Slider(
          value: hours.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          label: '$hours hrs',
          activeColor: AppColors.ink900,
          onChanged: (value) => setState(() => _dailyStudyHours = value.round()),
        ),
      ],
    );
  }

  Widget _buildPreparationLevelPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparation Level',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Wrap(
          spacing: AppConstants.spaceSm,
          children: PreparationLevel.values.map((level) {
            final isSelected = _preparationLevel == level;
            return ChoiceChip(
              label: Text(level.displayName),
              selected: isSelected,
              onSelected: (_) => setState(() => _preparationLevel = level),
              selectedColor: AppColors.ink900,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.lightOnPrimary : AppColors.ink900,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _avatarColor(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.startsWith('avatar:')) {
      final key = avatarUrl.substring('avatar:'.length);
      return _avatarPalette[key] ?? AppColors.ink900;
    }
    return AppColors.ink900;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _examName(String? examId) {
    if (examId == null) return 'Not set';
    return _exams
        .firstWhere(
          (exam) => exam.id == examId,
          orElse: () => Exam(id: examId, name: examId),
        )
        .name;
  }

  String _preparationLevelName(String? level) {
    if (level == null) return 'Not set';
    return PreparationLevel.values
        .firstWhere((l) => l.name == level, orElse: () => PreparationLevel.beginner)
        .displayName;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  const _AvatarPickerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.graphite700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Choose an avatar color',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Wrap(
            spacing: AppConstants.spaceMd,
            runSpacing: AppConstants.spaceMd,
            alignment: WrapAlignment.center,
            children: _avatarPalette.entries.map((entry) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, entry.key),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: entry.value,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spaceLg),
        ],
      ),
    );
  }
}
