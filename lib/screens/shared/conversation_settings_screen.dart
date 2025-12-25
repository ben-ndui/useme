import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Settings screen for a conversation.
class ConversationSettingsScreen extends StatefulWidget {
  final String conversationId;

  const ConversationSettingsScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationSettingsScreen> createState() =>
      _ConversationSettingsScreenState();
}

class _ConversationSettingsScreenState
    extends State<ConversationSettingsScreen> {
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthAuthenticatedState ? authState.user.id : '';

    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        BaseConversation? conversation;

        if (state is ChatOpenState) {
          conversation = state.conversation;
        } else if (state is ConversationsLoadedState) {
          conversation = state.conversations
              .cast<BaseConversation?>()
              .firstWhere(
                (c) => c?.id == widget.conversationId,
                orElse: () => null,
              );
        }

        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.conversationSettings)),
            body: const AppLoader(),
          );
        }

        final displayName = conversation.getDisplayName(currentUserId);
        final avatarUrl = conversation.getAvatarUrl(currentUserId);
        final isGroup = conversation.type == ConversationType.group;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.conversationSettings)),
          body: ListView(
            children: [
              const SizedBox(height: 24),

              // Avatar and name header
              Center(
                child: Column(
                  children: [
                    _buildAvatar(displayName, avatarUrl, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isGroup)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.participants(conversation.participantIds.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),

              // Profile section
              _buildSectionHeader(context, l10n.profile),
              _buildTile(
                context,
                icon: FontAwesomeIcons.user,
                title: l10n.viewProfile,
                subtitle: isGroup ? l10n.viewParticipants : l10n.information,
                onTap: () => _showProfile(conversation!, currentUserId),
              ),

              const Divider(height: 32),

              // Notifications section
              _buildSectionHeader(context, l10n.notifications),
              _buildSwitchTile(
                context,
                icon: _isMuted
                    ? FontAwesomeIcons.bellSlash
                    : FontAwesomeIcons.bell,
                title: l10n.notificationsMuted,
                subtitle: _isMuted ? l10n.notificationsEnabled : l10n.notificationsDisabled,
                value: _isMuted,
                onChanged: (value) {
                  setState(() => _isMuted = value);
                  // TODO: Persist mute state
                },
              ),

              const Divider(height: 32),

              // Danger zone
              _buildSectionHeader(context, l10n.actions),
              _buildTile(
                context,
                icon: FontAwesomeIcons.ban,
                title: l10n.block,
                subtitle: l10n.blockContact,
                isDestructive: true,
                onTap: () => _showBlockDialog(l10n, displayName),
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.flag,
                title: l10n.report,
                subtitle: l10n.reportProblem,
                isDestructive: true,
                onTap: () => _showReportDialog(l10n),
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.rightFromBracket,
                title: l10n.leaveConversation,
                subtitle: l10n.deleteFromList,
                isDestructive: true,
                onTap: () => _showLeaveDialog(l10n, displayName),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl, {double size = 40}) {
    final theme = Theme.of(context);

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size / 2.5,
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: FaIcon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: theme.colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(icon, size: 18, color: theme.colorScheme.primary),
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showProfile(BaseConversation conversation, String currentUserId) {
    // For now, navigate to profile route
    // In a real app, you'd get the other participant's ID and navigate to their profile
    context.push(AppRoutes.profile);
  }

  void _showBlockDialog(AppLocalizations l10n, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.blockConfirmTitle),
        content: Text(l10n.blockConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement block
              AppSnackBar.success(context, l10n.blocked(name));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.block),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reportConfirmTitle),
        content: Text(l10n.reportConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement report
              AppSnackBar.success(context, l10n.reportSent);
            },
            child: Text(l10n.report),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(AppLocalizations l10n, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.leaveConfirmTitle),
        content: Text(l10n.leaveConfirmMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Archive the conversation (soft delete)
              context.read<MessagingBloc>().add(
                    ToggleArchiveConversationEvent(
                      conversationId: widget.conversationId,
                      archived: true,
                    ),
                  );
              // Go back to conversations list
              context.go(AppRoutes.conversations);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
  }
}
