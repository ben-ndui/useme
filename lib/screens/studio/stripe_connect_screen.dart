import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/deep_link_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Screen for studios to connect their Stripe account and receive payments.
class StripeConnectScreen extends StatelessWidget {
  const StripeConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionPaymentBloc(),
      child: const _StripeConnectBody(),
    );
  }
}

class _StripeConnectBody extends StatefulWidget {
  const _StripeConnectBody();

  @override
  State<_StripeConnectBody> createState() => _StripeConnectBodyState();
}

class _StripeConnectBodyState extends State<_StripeConnectBody>
    with WidgetsBindingObserver {
  bool _waitingForOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
    // Listen for deep link return from Stripe onboarding
    DeepLinkService().onStripeConnectCallback = (completed) {
      if (mounted) {
        _checkStatus();
        if (completed) {
          AppSnackBar.success(
            context,
            AppLocalizations.of(context)!.stripeConnected,
          );
        }
      }
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkService().onStripeConnectCallback = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-refresh when user returns to app after onboarding in browser
    if (state == AppLifecycleState.resumed && _waitingForOnboarding) {
      _waitingForOnboarding = false;
      _checkStatus();
    }
  }

  void _checkStatus() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<SessionPaymentBloc>().add(
            CheckConnectStatusEvent(studioUserId: authState.user.uid),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stripeConnect),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: BlocConsumer<SessionPaymentBloc, SessionPaymentState>(
        listener: (context, state) {
          if (state is ConnectOnboardingLaunchedState) {
            AppSnackBar.success(context, l10n.stripeConnectPending);
          } else if (state is SessionPaymentFailedState) {
            AppSnackBar.error(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state is SessionPaymentLoadingState) {
            return const AppLoader();
          }

          if (state is ConnectStatusLoadedState) {
            return _ConnectStatusView(
              status: state.status,
              onConnect: _startOnboarding,
              onRefresh: _checkStatus,
            );
          }

          return _ConnectStatusView(
            status: null,
            onConnect: _startOnboarding,
            onRefresh: _checkStatus,
          );
        },
      ),
    );
  }

  void _startOnboarding() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      _waitingForOnboarding = true;
      context.read<SessionPaymentBloc>().add(
            InitiateConnectOnboardingEvent(userId: authState.user.uid),
          );
    }
  }
}

class _ConnectStatusView extends StatelessWidget {
  final dynamic status;
  final VoidCallback onConnect;
  final VoidCallback onRefresh;

  const _ConnectStatusView({
    required this.status,
    required this.onConnect,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isConnected = status?.connected == true;
    final isActive = status?.isFullyActive == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Icon(
            isActive
                ? FontAwesomeIcons.solidCircleCheck
                : FontAwesomeIcons.stripe,
            size: 56,
            color: isActive ? Colors.green : theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.stripeConnect,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.stripeConnectSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Status indicators — only show when not fully active yet
          // (avoids confusing red crosses in test mode when detailsSubmitted)
          if (isConnected && !isActive) ...[
            _StatusRow(
              label: l10n.stripePaymentsEnabled,
              enabled: status.chargesEnabled,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _StatusRow(
              label: l10n.stripePayoutsEnabled,
              enabled: status.payoutsEnabled,
              theme: theme,
            ),
            const SizedBox(height: 24),
          ],
          // Action button
          if (!isActive) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onConnect,
                icon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare,
                    size: 16),
                label: Text(
                  isConnected
                      ? l10n.stripeConnectPending
                      : l10n.connectStripe,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 14),
              label: Text(l10n.refresh),
            ),
          ],
          if (isActive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.solidCircleCheck,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.stripeConnected,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text(
            l10n.platformFeeNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool enabled;
  final ThemeData theme;

  const _StatusRow({
    required this.label,
    required this.enabled,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          enabled
              ? FontAwesomeIcons.solidCircleCheck
              : FontAwesomeIcons.solidCircleXmark,
          size: 16,
          color: enabled ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
