import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/screens/shared/conversations_screen.dart';
import 'studio_dashboard_page.dart';
import 'sessions_page.dart';
import 'artists_page.dart';
import 'studio_settings_page.dart';

/// Main scaffold for Studio with modern bottom navigation
class StudioMainScaffold extends StatefulWidget {
  final int initialPage;

  const StudioMainScaffold({super.key, this.initialPage = 0});

  @override
  State<StudioMainScaffold> createState() => _StudioMainScaffoldState();
}

class _StudioMainScaffoldState extends State<StudioMainScaffold> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = const [
    StudioDashboardPage(),
    SessionsPage(),
    ArtistsPage(),
    ConversationsScreen(),
    StudioSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      context.read<SessionBloc>().add(LoadSessionsEvent(studioId: user.uid));
      context.read<ArtistBloc>().add(LoadArtistsEvent(studioId: user.uid));
      context.read<ServiceBloc>().add(LoadServicesEvent(studioId: user.uid));
      context.read<FavoriteBloc>().add(LoadFavoritesEvent(userId: user.uid));

      // Configure l'utilisateur pour la messagerie
      final messagingBloc = context.read<MessagingBloc>();
      messagingBloc.setCurrentUser(
        userId: user.uid,
        userName: user.displayName ?? user.name ?? 'Studio',
        avatarUrl: user.photoURL,
      );
      messagingBloc.add(LoadConversationsEvent(userId: user.uid));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          // Navigate to home page instead of exiting
          _onNavTap(0);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        extendBody: true,
        bottomNavigationBar: _ModernBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          l10n: l10n,
        ),
      ),
    );
  }
}

// =============================================================================
// MODERN BOTTOM NAV
// =============================================================================

class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l10n;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: FontAwesomeIcons.house,
                  activeIcon: FontAwesomeIcons.house,
                  label: l10n.home,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: FontAwesomeIcons.calendar,
                  activeIcon: FontAwesomeIcons.solidCalendar,
                  label: l10n.sessionsLabel,
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: FontAwesomeIcons.users,
                  activeIcon: FontAwesomeIcons.userGroup,
                  label: l10n.artistsLabel,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _MessagesNavItem(
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                  messagesLabel: l10n.messages,
                ),
                _NavItem(
                  icon: FontAwesomeIcons.gear,
                  activeIcon: FontAwesomeIcons.gear,
                  label: l10n.settings,
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget isolé pour l'item Messages avec BlocBuilder
class _MessagesNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String messagesLabel;

  const _MessagesNavItem({
    required this.isSelected,
    required this.onTap,
    required this.messagesLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      buildWhen: (previous, current) {
        // Ne rebuild que si le unreadCount change
        final prevCount = previous is ConversationsLoadedState ? previous.totalUnreadCount : 0;
        final currCount = current is ConversationsLoadedState ? current.totalUnreadCount : 0;
        return prevCount != currCount;
      },
      builder: (context, state) {
        final unreadCount = state is ConversationsLoadedState ? state.totalUnreadCount : 0;
        return _NavItem(
          icon: FontAwesomeIcons.comment,
          activeIcon: FontAwesomeIcons.solidComment,
          label: messagesLabel,
          isSelected: isSelected,
          onTap: onTap,
          badgeCount: unreadCount,
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: FaIcon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
