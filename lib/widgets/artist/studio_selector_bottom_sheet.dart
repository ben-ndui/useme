import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Simple studio info for selection
class StudioInfo {
  final String id;
  final String name;
  final String? photoUrl;

  const StudioInfo({required this.id, required this.name, this.photoUrl});
}

/// Bottom sheet for selecting a studio before booking
class StudioSelectorBottomSheet extends StatefulWidget {
  final void Function(StudioInfo studio) onStudioSelected;

  const StudioSelectorBottomSheet({super.key, required this.onStudioSelected});

  /// Shows the bottom sheet and navigates to session request on selection
  static void showAndNavigate(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: authBloc,
        child: StudioSelectorBottomSheet(
          onStudioSelected: (studio) {
            Navigator.pop(sheetContext);
            context.push('/artist/request?studioId=${studio.id}&studioName=${Uri.encodeComponent(studio.name)}');
          },
        ),
      ),
    );
  }

  @override
  State<StudioSelectorBottomSheet> createState() => _StudioSelectorBottomSheetState();
}

class _StudioSelectorBottomSheetState extends State<StudioSelectorBottomSheet> {
  List<StudioInfo> _studios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudios();
  }

  Future<void> _loadStudios() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) {
      setState(() {
        _isLoading = false;
        _error = 'Non authentifié';
      });
      return;
    }

    final user = authState.user as AppUser;
    final studioIds = user.studioIds;

    if (studioIds.isEmpty) {
      setState(() {
        _isLoading = false;
        _studios = [];
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final studios = <StudioInfo>[];

      // Fetch each studio's info
      for (final studioId in studioIds) {
        final doc = await firestore.collection('users').doc(studioId).get();
        if (doc.exists) {
          final data = doc.data()!;
          final studioProfile = data['studioProfile'] as Map<String, dynamic>?;
          studios.add(StudioInfo(
            id: studioId,
            name: studioProfile?['name'] ?? data['displayName'] ?? data['name'] ?? 'Studio',
            photoUrl: studioProfile?['photoUrl'] ?? data['photoURL'],
          ));
        }
      }

      setState(() {
        _studios = studios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur de chargement';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(theme),
          _buildHeader(theme, l10n),
          const SizedBox(height: 8),
          _buildContent(theme, l10n),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(FontAwesomeIcons.building, size: 18, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectStudio,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.selectStudioDescription,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations l10n) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ),
      );
    }

    if (_studios.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _studios.length,
      itemBuilder: (context, index) => _buildStudioTile(theme, _studios[index]),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: FaIcon(FontAwesomeIcons.buildingCircleXmark, size: 32, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noLinkedStudios,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noLinkedStudiosDescription,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to artist portal (map view) to explore studios
              context.go('/artist');
            },
            icon: const FaIcon(FontAwesomeIcons.mapLocationDot, size: 14),
            label: Text(l10n.discoverStudios),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioTile(ThemeData theme, StudioInfo studio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => widget.onStudioSelected(studio),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: studio.photoUrl != null ? NetworkImage(studio.photoUrl!) : null,
          child: studio.photoUrl == null
              ? Text(
                  studio.name[0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                )
              : null,
        ),
        title: Text(
          studio.name,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Réserver',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
