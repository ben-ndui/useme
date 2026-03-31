import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/card_config/card_config_exports.dart';
import 'package:useme/core/blocs/network/network_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/card_config.dart';
import 'package:useme/core/models/user_contact.dart';
import 'package:useme/core/services/card_stats_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/card/holo_card.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Bottom sheet shown after scanning a QR code.
/// Displays the scanned user's HoloCard and offers to add them.
class ScannedContactSheet extends StatefulWidget {
  final String scannedUserId;

  const ScannedContactSheet({super.key, required this.scannedUserId});

  static Future<void> show(BuildContext context, String scannedUserId) {
    final authBloc = context.read<AuthBloc>();
    final networkBloc = context.read<NetworkBloc>();
    final cardConfigBloc = context.read<CardConfigBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: networkBloc),
            BlocProvider.value(value: cardConfigBloc),
          ],
          child: ScannedContactSheet(scannedUserId: scannedUserId),
        );
      },
    );
  }

  @override
  State<ScannedContactSheet> createState() => _ScannedContactSheetState();
}

class _ScannedContactSheetState extends State<ScannedContactSheet> {
  AppUser? _scannedUser;
  CardConfig? _scannedCardConfig;
  bool _isLoading = true;
  bool _isAdding = false;
  bool _alreadyAdded = false;
  ContactCategory _selectedCategory = ContactCategory.other;

  @override
  void initState() {
    super.initState();
    _loadScannedUser();
  }

  Future<void> _loadScannedUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.scannedUserId)
          .get();

      if (!mounted || doc.data() == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = AppUser.fromMap(doc.data()!, doc.id);

      // Record scan stat
      CardStatsService().recordScan(widget.scannedUserId);

      final cardConfigData = doc.data()!['cardConfig'];
      final cardConfig = cardConfigData != null
          ? CardConfig.fromMap(cardConfigData as Map<String, dynamic>)
          : const CardConfig();

      // Auto-detect category from role
      final category = switch (user.role) {
        BaseUserRole.admin || BaseUserRole.superAdmin =>
          ContactCategory.studio,
        BaseUserRole.worker => ContactCategory.engineer,
        _ => ContactCategory.artist,
      };

      // Check if already in contacts
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticatedState) {
        final contacts = context.read<NetworkBloc>().state.contacts;
        _alreadyAdded = contacts.any(
            (c) => c.contactUserId == widget.scannedUserId);
      }

      setState(() {
        _scannedUser = user;
        _scannedCardConfig = cardConfig;
        _selectedCategory = category;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addToNetwork() async {
    final user = _scannedUser;
    if (user == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    setState(() => _isAdding = true);

    context.read<NetworkBloc>().add(AddPlatformContactEvent(
          userId: authState.user.uid,
          contact: user,
          category: _selectedCategory,
        ));

    // Small delay for UX feedback
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(context);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactAdded)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.7,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.surfaceContainerHigh,
                cs.surface.withValues(alpha: 0.95),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: cs.outlineVariant, width: 1),
            ),
          ),
          child: _isLoading
              ? const AppLoader.fullScreen()
              : _scannedUser == null
                  ? _buildNotFound(l10n, cs)
                  : _buildContent(l10n, cs),
        ),
      ),
    );
  }

  Widget _buildNotFound(AppLocalizations l10n, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.userSlash,
              size: 40, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            l10n.userNotFound,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: cs.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          l10n.scannedProfile,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),

        // Card preview
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: HoloCard(
                user: _scannedUser!,
                cardConfig: _scannedCardConfig,
              ),
            ),
          ),
        ),

        // Category selector
        if (!_alreadyAdded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildCategoryChips(cs),
          ),
        const SizedBox(height: 16),

        // Action button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: _alreadyAdded
                ? OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: FaIcon(FontAwesomeIcons.circleCheck,
                        size: 16, color: cs.primary),
                    label: Text(l10n.alreadyInNetwork),
                  )
                : ElevatedButton.icon(
                    onPressed: _isAdding ? null : _addToNetwork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: _isAdding
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const FaIcon(FontAwesomeIcons.userPlus, size: 16),
                    label: Text(
                      _isAdding ? l10n.adding : l10n.addToNetwork,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
      ],
    );
  }

  Widget _buildCategoryChips(ColorScheme cs) {
    return Wrap(
      spacing: 8,
      children: ContactCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        return ChoiceChip(
          label: Text(cat.label),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedCategory = cat),
          selectedColor: cs.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            fontSize: 12,
          ),
          side: BorderSide(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }
}
