import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Toggle pour autoriser les réservations sans ingénieur
class AllowNoEngineerToggle extends StatefulWidget {
  final String userId;

  const AllowNoEngineerToggle({super.key, required this.userId});

  @override
  State<AllowNoEngineerToggle> createState() => _AllowNoEngineerToggleState();
}

class _AllowNoEngineerToggleState extends State<AllowNoEngineerToggle> {
  bool _allowNoEngineer = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValue();
  }

  void _loadCurrentValue() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser && user.studioProfile != null) {
        setState(() {
          _allowNoEngineer = user.studioProfile!.allowNoEngineer;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.userSlash,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.allowNoEngineer,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.allowNoEngineerSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (_isSaving)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch(
                value: _allowNoEngineer,
                onChanged: _onToggle,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onToggle(bool value) async {
    setState(() {
      _allowNoEngineer = value;
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'studioProfile.allowNoEngineer': value});

      if (mounted) {
        context.read<AuthBloc>().add(const ReloadUserEvent());
        setState(() => _isSaving = false);
        AppSnackBar.success(
          context,
          AppLocalizations.of(context)!.settingsSaved,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allowNoEngineer = !value;
          _isSaving = false;
        });
        AppSnackBar.error(
          context,
          '${AppLocalizations.of(context)!.errorOccurred}: $e',
        );
      }
    }
  }
}
