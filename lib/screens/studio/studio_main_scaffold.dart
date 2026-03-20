import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/screens/shared/conversations_screen.dart';
import 'package:useme/widgets/common/app_navigation_rail.dart';
import 'package:useme/widgets/studio/studio_bottom_nav.dart';
import 'studio_dashboard_page.dart';
import 'sessions_page.dart';
import 'artists_page.dart';
import 'studio_settings_page.dart';

/// Main scaffold for Studio with adaptive navigation
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
      _syncMessagingUser(user);
      context.read<MessagingBloc>().add(LoadConversationsEvent(userId: user.uid));
    }
  }

  void _syncMessagingUser(BaseUser user) {
    context.read<MessagingBloc>().setCurrentUser(
      userId: user.uid,
      userName: user.displayName ?? user.name ?? 'Studio',
      avatarUrl: user.photoURL,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (context.isTabletOrLarger) {
      setState(() => _currentIndex = index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
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
          icon: FontAwesomeIcons.calendar,
          selectedIcon: FontAwesomeIcons.solidCalendar,
          label: l10n.sessionsLabel,
          badgeCount: pendingCount,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.users,
          selectedIcon: FontAwesomeIcons.userGroup,
          label: l10n.artistsLabel,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.comment,
          selectedIcon: FontAwesomeIcons.solidComment,
          label: l10n.messages,
          isMessages: true,
        ),
        AppNavRailItem(
          icon: FontAwesomeIcons.gear,
          selectedIcon: FontAwesomeIcons.gear,
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
        if (!didPop && _currentIndex != 0) _onNavTap(0);
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev is AuthAuthenticatedState &&
            curr is AuthAuthenticatedState &&
            prev.user.photoURL != curr.user.photoURL,
        listener: (context, state) {
          if (state is AuthAuthenticatedState) {
            _syncMessagingUser(state.user);
          }
        },
        child: isWide
            ? _buildWideScaffold(l10n)
            : _buildMobileScaffold(l10n),
      ),
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
                onDestinationSelected: _onNavTap,
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: BlocBuilder<SessionBloc, SessionState>(
        buildWhen: (prev, curr) => prev.pendingCount != curr.pendingCount,
        builder: (context, sessionState) {
          return StudioBottomNav(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
            l10n: l10n,
            pendingSessionCount: sessionState.pendingCount,
          );
        },
      ),
    );
  }
}
