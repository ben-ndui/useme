import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'pro_type_selector.dart';
import 'pro_profile_form_fields.dart';

/// Ecran de création / édition du profil pro.
class ProProfileSetupScreen extends StatefulWidget {
  const ProProfileSetupScreen({super.key});

  @override
  State<ProProfileSetupScreen> createState() => _ProProfileSetupScreenState();
}

class _ProProfileSetupScreenState extends State<ProProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _cityController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;

  List<ProType> _selectedTypes = [];
  List<String> _specialties = [];
  List<String> _instruments = [];
  List<String> _genres = [];
  List<String> _daws = [];
  bool _remote = false;
  bool _isAvailable = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _hourlyRateController = TextEditingController();
    _cityController = TextEditingController();
    _websiteController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingProfile();
    });
  }

  void _loadExistingProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final user = authState.user as dynamic;
    final profile = user.proProfile as ProProfile?;
    if (profile == null) return;

    setState(() {
      _isEditing = true;
      _displayNameController.text = profile.displayName;
      _bioController.text = profile.bio ?? '';
      _hourlyRateController.text =
          profile.hourlyRate?.toStringAsFixed(0) ?? '';
      _cityController.text = profile.city ?? '';
      _websiteController.text = profile.website ?? '';
      _phoneController.text = profile.phone ?? '';
      _selectedTypes = List.from(profile.proTypes);
      _specialties = List.from(profile.specialties);
      _instruments = List.from(profile.instruments);
      _genres = List.from(profile.genres);
      _daws = List.from(profile.daws);
      _remote = profile.remote;
      _isAvailable = profile.isAvailable;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _cityController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ProProfileBloc, ProProfileState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppSnackBar.success(context, state.successMessage!);
          context.pop();
        }
        if (state.errorMessage != null) {
          AppSnackBar.error(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.proProfileEdit : l10n.proProfileSetup),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Responsive.maxFormWidth),
            child: BlocBuilder<ProProfileBloc, ProProfileState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 24),
                  ProTypeSelector(
                    selectedTypes: _selectedTypes,
                    onChanged: (types) =>
                        setState(() => _selectedTypes = types),
                  ),
                  const SizedBox(height: 24),
                  ProProfileFormFields(
                    displayNameController: _displayNameController,
                    bioController: _bioController,
                    hourlyRateController: _hourlyRateController,
                    cityController: _cityController,
                    websiteController: _websiteController,
                    phoneController: _phoneController,
                    specialties: _specialties,
                    instruments: _instruments,
                    genres: _genres,
                    daws: _daws,
                    remote: _remote,
                    isAvailable: _isAvailable,
                    selectedTypes: _selectedTypes,
                    onSpecialtiesChanged: (v) =>
                        setState(() => _specialties = v),
                    onInstrumentsChanged: (v) =>
                        setState(() => _instruments = v),
                    onGenresChanged: (v) => setState(() => _genres = v),
                    onDawsChanged: (v) => setState(() => _daws = v),
                    onRemoteChanged: (v) => setState(() => _remote = v),
                    onAvailabilityChanged: (v) =>
                        setState(() => _isAvailable = v),
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(state, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UseMeTheme.accentColor.withValues(alpha: 0.12),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.briefcase,
              size: 28,
              color: UseMeTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isEditing ? l10n.proProfileEdit : l10n.proProfileSetup,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.proProfileSetupDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ProProfileState state, AppLocalizations l10n) {
    return FilledButton.icon(
      onPressed: state.isSaving ? null : _submit,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: state.isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FaIcon(
              _isEditing
                  ? FontAwesomeIcons.floppyDisk
                  : FontAwesomeIcons.rocket,
              size: 16,
            ),
      label: Text(
        _isEditing ? l10n.save : l10n.proProfileActivate,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTypes.isEmpty) {
      AppSnackBar.warning(
        context,
        AppLocalizations.of(context)!.proProfileSelectType,
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final rate = double.tryParse(_hourlyRateController.text);

    final profile = ProProfile(
      displayName: _displayNameController.text.trim(),
      proTypes: _selectedTypes,
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      specialties: _specialties,
      instruments: _instruments,
      genres: _genres,
      daws: _daws,
      hourlyRate: rate,
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      remote: _remote,
      isAvailable: _isAvailable,
    );

    final bloc = context.read<ProProfileBloc>();
    if (_isEditing) {
      bloc.add(UpdateProProfileEvent(
        userId: authState.user.uid,
        profile: profile,
      ));
    } else {
      bloc.add(ActivateProProfileEvent(
        userId: authState.user.uid,
        profile: profile,
      ));
    }
  }
}
