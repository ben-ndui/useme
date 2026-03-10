import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/screens/artist/artist_portal_page.dart';
import 'package:useme/screens/artist/artist_sessions_page.dart';
import 'package:useme/screens/artist/artist_settings_page.dart';
import 'package:useme/screens/shared/conversations_screen.dart';
import 'package:useme/screens/shared/favorites_screen.dart';
import 'package:useme/widgets/common/app_navigation_rail.dart';
import 'package:useme/widgets/common/floating_bottom_nav.dart';

/// Main scaffold for Artist role with adaptive navigation
class ArtistMainScaffold extends StatefulWidget {
  final int initialPage;

  const ArtistMainScaffold({super.key, this.initialPage = 0});

  @override
  State<ArtistMainScaffold> createState() => _ArtistMainScaffoldState();
}

class _ArtistMainScaffoldState extends State<ArtistMainScaffold> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = const [
    ArtistPortalPage(),
    ArtistSessionsPage(),
    FavoritesScreen(),
    ConversationsScreen(),
    ArtistSettingsPage(),
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
      context.read<SessionBloc>().add(LoadArtistSessionsEvent(artistId: user.uid));
      context.read<FavoriteBloc>().add(LoadFavoritesEvent(userId: user.uid));
      context.read<NetworkBloc>().add(LoadContactsEvent(userId: user.uid));

      final messagingBloc = context.read<MessagingBloc>();
      messagingBloc.setCurrentUser(
        userId: user.uid,
        userName: user.displayName ?? user.name ?? 'Artiste',
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

  void _onNavTapped(int index) {
    if (context.isTabletOrLarger) {
      setState(() => _currentIndex = index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<AppNavRailItem> _railItems(AppLocalizations l10n, {int pendingCount = 0}) => [
        AppNavRailItem(
          icon: FontAwesomeIcons.house,
          selectedIcon: FontAwesomeIcons.houseChimney,
          label: l10n.home,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.calendarDays,
          selectedIcon: FontAwesomeIcons.calendarCheck,
          label: l10n.sessionsLabel,
          badgeCount: pendingCount,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.heart,
          selectedIcon: FontAwesomeIcons.solidHeart,
          label: l10n.favorites,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.comment,
          selectedIcon: FontAwesomeIcons.solidComment,
          label: l10n.messages,
          isMessages: true,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.gear,
          selectedIcon: FontAwesomeIcons.gears,
          label: l10n.settings,
          badgeCount: pendingCount,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = context.isTabletOrLarger;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) _onNavTapped(0);
      },
      child: isWide
          ? _buildWideScaffold(l10n)
          : _buildMobileScaffold(l10n),
    );
  }

  Widget _buildWideScaffold(AppLocalizations l10n) {
    return Scaffold(
      body: BlocBuilder<SessionBloc, SessionState>(
        buildWhen: (prev, curr) => prev.pendingCount != curr.pendingCount,
        builder: (context, sessionState) {
          return Row(
            children: [
              AppNavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onNavTapped,
                items: _railItems(l10n, pendingCount: sessionState.pendingCount),
              ),
              Expanded(child: _pages[_currentIndex]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileScaffold(AppLocalizations l10n) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        physics: _currentIndex == 0
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BlocBuilder<SessionBloc, SessionState>(
        buildWhen: (prev, curr) => prev.pendingCount != curr.pendingCount,
        builder: (context, sessionState) {
          return BlocBuilder<MessagingBloc, MessagingState>(
            buildWhen: (previous, current) {
              final prevCount = previous is ConversationsLoadedState ? previous.totalUnreadCount : 0;
              final currCount = current is ConversationsLoadedState ? current.totalUnreadCount : 0;
              return prevCount != currCount;
            },
            builder: (context, messagingState) {
              final unreadCount = messagingState is ConversationsLoadedState
                  ? messagingState.totalUnreadCount
                  : 0;

              return FloatingBottomNav(
                currentIndex: _currentIndex,
                onTap: _onNavTapped,
                items: [
                  FloatingNavItem(
                    icon: FontAwesomeIcons.house,
                    selectedIcon: FontAwesomeIcons.houseChimney,
                    label: l10n.home,
                  ),
                  FloatingNavItem(
                    icon: FontAwesomeIcons.calendarDays,
                    selectedIcon: FontAwesomeIcons.calendarCheck,
                    label: l10n.sessionsLabel,
                    badgeCount: sessionState.pendingCount,
                  ),
                  FloatingNavItem(
                    icon: FontAwesomeIcons.heart,
                    selectedIcon: FontAwesomeIcons.solidHeart,
                    label: l10n.favorites,
                  ),
                  FloatingNavItem(
                    icon: FontAwesomeIcons.comment,
                    selectedIcon: FontAwesomeIcons.solidComment,
                    label: l10n.messages,
                    badgeCount: unreadCount,
                  ),
                  FloatingNavItem(
                    icon: FontAwesomeIcons.gear,
                    selectedIcon: FontAwesomeIcons.gears,
                    label: l10n.settings,
                    badgeCount: sessionState.pendingCount,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
