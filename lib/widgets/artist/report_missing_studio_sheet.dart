import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Bottom sheet pour signaler un studio manquant.
class ReportMissingStudioSheet extends StatefulWidget {
  const ReportMissingStudioSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportMissingStudioSheet(),
    );
  }

  @override
  State<ReportMissingStudioSheet> createState() => _ReportMissingStudioSheetState();
}

class _ReportMissingStudioSheetState extends State<ReportMissingStudioSheet> {
  final _formKey = GlobalKey<FormState>();
  final _studioNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _studioNameController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = context.read<AuthBloc>().state;
      String? userId;
      String? userEmail;
      if (authState is AuthAuthenticatedState) {
        userId = authState.user.uid;
        userEmail = authState.user.email;
      }

      await FirebaseFirestore.instance.collection('studio_requests').add({
        'studioName': _studioNameController.text.trim(),
        'city': _cityController.text.trim(),
        'notes': _notesController.text.trim(),
        'requestedByUserId': userId,
        'requestedByEmail': userEmail,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        AppSnackBar.error(context, 'Erreur: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isSuccess ? _buildSuccessContent(theme, l10n) : _buildFormContent(theme, l10n),
    );
  }

  Widget _buildSuccessContent(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.check, color: Colors.green, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.requestSubmitted,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.weWillVerifyAndAddStudio,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.buildingCircleExclamation,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.missingStudio,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.tellUsWhichStudio,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Studio name field
            TextFormField(
              controller: _studioNameController,
              decoration: InputDecoration(
                labelText: l10n.studioName,
                hintText: l10n.studioNameExample,
                prefixIcon: const Icon(FontAwesomeIcons.microphone, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterStudioName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // City field
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: l10n.city,
                hintText: l10n.cityExample,
                prefixIcon: const Icon(FontAwesomeIcons.locationDot, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterCity;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notesOptionalLabel,
                hintText: l10n.notesHint,
                prefixIcon: const Icon(FontAwesomeIcons.noteSticky, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Submit button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
              label: Text(_isSubmitting ? l10n.sending : l10n.sendRequestLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
