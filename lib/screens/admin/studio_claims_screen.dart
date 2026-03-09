import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/models/studio_claim.dart';
import 'package:useme/core/services/studio_claim_approval_service.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Écran super admin pour gérer les demandes de revendication de studios
class StudioClaimsScreen extends StatefulWidget {
  const StudioClaimsScreen({super.key});

  @override
  State<StudioClaimsScreen> createState() => _StudioClaimsScreenState();
}

class _StudioClaimsScreenState extends State<StudioClaimsScreen> {
  final StudioClaimApprovalService _service = StudioClaimApprovalService();
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminStudioClaims),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showAll = !_showAll),
            icon: FaIcon(_showAll ? FontAwesomeIcons.filter : FontAwesomeIcons.list, size: 14),
            label: Text(_showAll ? l10n.adminFilterPending : l10n.adminFilterAll),
          ),
        ],
      ),
      body: StreamBuilder<List<StudioClaim>>(
        stream: _showAll ? _service.streamAllClaims() : _service.streamPendingClaims(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }

          final claims = snapshot.data ?? [];

          if (claims.isEmpty) {
            return _buildEmptyState(context);
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: claims.length,
                itemBuilder: (ctx, i) => _ClaimCard(
                  claim: claims[i],
                  onApprove: () => _approveClaim(claims[i]),
                  onReject: () => _showRejectDialog(claims[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.buildingCircleCheck, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(l10n.adminNoClaimsPending, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.adminNewClaimsAppearHere,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Future<void> _approveClaim(StudioClaim claim) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      await _service.approveClaim(claimId: claim.id, reviewerId: authState.user.uid);
      if (mounted) {
        AppSnackBar.success(context, l10n.adminClaimApproved(claim.studioProfile.name));
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorWithMessage(e.toString()));
      }
    }
  }

  Future<void> _showRejectDialog(StudioClaim claim) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminRejectClaim),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.adminRejectClaimConfirm(claim.studioProfile.name)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.adminReasonOptional,
                hintText: l10n.adminReasonHint,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.adminReject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _rejectClaim(claim, controller.text.trim());
    }
    controller.dispose();
  }

  Future<void> _rejectClaim(StudioClaim claim, String? reason) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      await _service.rejectClaim(
        claimId: claim.id,
        reviewerId: authState.user.uid,
        reason: reason?.isNotEmpty == true ? reason : null,
      );
      if (mounted) {
        AppSnackBar.info(context, l10n.adminClaimRejected);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorWithMessage(e.toString()));
      }
    }
  }
}

/// Card pour afficher une demande de revendication
class _ClaimCard extends StatelessWidget {
  final StudioClaim claim;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ClaimCard({required this.claim, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd('fr_FR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildStatusBadge(theme, l10n),
                const Spacer(),
                Text(dateFormat.format(claim.createdAt), style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),

            // Studio info
            Text(claim.studioProfile.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (claim.studioProfile.address?.isNotEmpty == true)
              Text(claim.studioProfile.address!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),

            // User info
            Row(
              children: [
                FaIcon(FontAwesomeIcons.user, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Text(claim.userName, style: theme.textTheme.bodySmall),
                const SizedBox(width: 16),
                FaIcon(FontAwesomeIcons.envelope, size: 12, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(claim.userEmail,
                      style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),

            // Actions (only for pending)
            if (claim.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.adminReject),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: onApprove, child: Text(l10n.adminApprove))),
                ],
              ),
            ],

            // Rejection reason
            if (claim.isRejected && claim.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.circleXmark, size: 14, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(claim.rejectionReason!, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, AppLocalizations l10n) {
    final (color, label, icon) = switch (claim.status) {
      ClaimStatus.pending => (Colors.orange, l10n.adminStatusPending, FontAwesomeIcons.clock),
      ClaimStatus.approved => (Colors.green, l10n.adminStatusApproved, FontAwesomeIcons.circleCheck),
      ClaimStatus.rejected => (Colors.red, l10n.adminStatusRejected, FontAwesomeIcons.circleXmark),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
