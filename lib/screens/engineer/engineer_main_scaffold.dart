import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/screens/engineer/engineer_dashboard_page.dart';
import 'package:useme/screens/engineer/engineer_sessions_page.dart';
import 'package:useme/screens/engineer/engineer_settings_page.dart';
import 'package:useme/screens/shared/conversations_screen.dart';
import 'package:useme/screens/shared/favorites_screen.dart';
import 'package:useme/widgets/common/floating_bottom_nav.dart';

/// Main scaffold for Engineer role with floating bottom navigation
class EngineerMainScaffold extends StatefulWidget {
  final int initialPage;

  const EngineerMainScaffold({super.key, this.initialPage = 0});

  @override
  State<EngineerMainScaffold> createState() => _EngineerMainScaffoldState();
}

class _EngineerMainScaffoldState extends State<EngineerMainScaffold> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = const [
    EngineerDashboardPage(),
    EngineerSessionsPage(),
    FavoritesScreen(),
    ConversationsScreen(),
    EngineerSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageController = PageController(initialPage: _currentIndex);

    // Load data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;

      // Load sessions assigned to this engineer
      context.read<SessionBloc>().add(LoadEngineerSessionsEvent(engineerId: user.uid));
      context.read<FavoriteBloc>().add(LoadFavoritesEvent(userId: user.uid));

      // Configure l'utilisateur pour la messagerie
      final messagingBloc = context.read<MessagingBloc>();
      messagingBloc.setCurrentUser(
        userId: user.uid,
        userName: user.displayName ?? user.name ?? 'Ingénieur',
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

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
          _onNavTapped(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: BlocBuilder<MessagingBloc, MessagingState>(
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
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
