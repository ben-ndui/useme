import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/auth/glass_text_field.dart';

/// Bottom sheet for entering password when re-logging into an email account.
class PasswordBottomSheet extends StatefulWidget {
  final String displayName;
  final String email;
  final void Function(String password) onSubmit;

  const PasswordBottomSheet({
    super.key,
    required this.displayName,
    required this.email,
    required this.onSubmit,
  });

  /// Show the bottom sheet and return the entered password, or null if dismissed.
  static void show(
    BuildContext context, {
    required String displayName,
    required String email,
    required void Function(String password) onSubmit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasswordBottomSheet(
        displayName: displayName,
        email: email,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<PasswordBottomSheet> createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends State<PasswordBottomSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.enterPasswordFor(widget.displayName),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 20),
                GlassPasswordField(
                  controller: _controller,
                  hint: l10n.passwordHint,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  label: l10n.signIn,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final password = _controller.text.trim();
    if (password.isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit(password);
  }
}
