import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/auth/glass_text_field.dart';

/// Welcome back card shown when quick login is enabled
class QuickLoginCard extends StatefulWidget {
  final String displayName;
  final String email;
  final String role;
  final String provider;
  final String? photoUrl;
  final void Function(String? password) onConnect;
  final VoidCallback onSwitchAccount;

  const QuickLoginCard({
    super.key,
    required this.displayName,
    required this.email,
    required this.role,
    required this.provider,
    this.photoUrl,
    required this.onConnect,
    required this.onSwitchAccount,
  });

  @override
  State<QuickLoginCard> createState() => _QuickLoginCardState();
}

class _QuickLoginCardState extends State<QuickLoginCard> {
  final _passwordController = TextEditingController();

  bool get _isEmailProvider => widget.provider == 'email';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState ||
            state is AuthGoogleLoadingState ||
            state is AuthAppleLoadingState;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 32),
              _buildUserCard(),
              if (_isEmailProvider) ...[
                const SizedBox(height: 20),
                _buildPasswordField(l10n),
              ],
              const SizedBox(height: 24),
              _buildConnectButton(l10n, isLoading),
              const SizedBox(height: 20),
              _buildSwitchAccountLink(l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        const Text(
          'UZME',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 25,
          ),
        ),
        Text(
          l10n.welcomeBack,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    final initial = widget.displayName.isNotEmpty
        ? widget.displayName[0].toUpperCase()
        : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: widget.photoUrl != null
                    ? NetworkImage(widget.photoUrl!)
                    : null,
                child: widget.photoUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                widget.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              _buildRoleBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(_roleIcon, size: 12,
              color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(
            _roleLabel,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return GlassPasswordField(
      controller: _passwordController,
      hint: l10n.passwordHint,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onConnect(),
    );
  }

  Widget _buildConnectButton(AppLocalizations l10n, bool isLoading) {
    return GlassButton(
      label: l10n.signIn,
      isLoading: isLoading,
      onPressed: _onConnect,
    );
  }

  void _onConnect() {
    if (_isEmailProvider) {
      widget.onConnect(_passwordController.text);
    } else {
      widget.onConnect(null);
    }
  }

  Widget _buildSwitchAccountLink(AppLocalizations l10n) {
    return GestureDetector(
      onTap: widget.onSwitchAccount,
      child: Text(
        l10n.useAnotherAccount,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  IconData get _roleIcon {
    switch (widget.role) {
      case 'admin':
      case 'superAdmin':
        return FontAwesomeIcons.buildingColumns;
      case 'worker':
        return FontAwesomeIcons.headphones;
      default:
        return FontAwesomeIcons.microphone;
    }
  }

  String get _roleLabel {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.role) {
      case 'admin':
      case 'superAdmin':
        return l10n.studio;
      case 'worker':
        return l10n.engineer;
      default:
        return l10n.artist;
    }
  }
}
