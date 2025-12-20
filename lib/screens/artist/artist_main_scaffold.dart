import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/screens/artist/artist_portal_page.dart';
import 'package:useme/screens/artist/artist_sessions_page.dart';
import 'package:useme/screens/artist/artist_settings_page.dart';
import 'package:useme/screens/shared/conversations_screen.dart';
import 'package:useme/screens/shared/favorites_screen.dart';
import 'package:useme/widgets/common/floating_bottom_nav.dart';

/// Main scaffold for Artist role with floating bottom navigation
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final userId = authState.user.uid;
      context.read<SessionBloc>().add(LoadArtistSessionsEvent(artistId: userId));
      context.read<MessagingBloc>().add(LoadConversationsEvent(userId: userId));
      context.read<FavoriteBloc>().add(LoadFavoritesEvent(userId: userId));
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
    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, messagingState) {
        final unreadCount = messagingState is ConversationsLoadedState
            ? messagingState.totalUnreadCount
            : 0;

        return Scaffold(
          extendBody: true,
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          bottomNavigationBar: FloatingBottomNav(
            currentIndex: _currentIndex,
            onTap: _onNavTapped,
            items: [
              const FloatingNavItem(
                icon: FontAwesomeIcons.house,
                selectedIcon: FontAwesomeIcons.houseChimney,
                label: 'Accueil',
              ),
              const FloatingNavItem(
                icon: FontAwesomeIcons.calendarDays,
                selectedIcon: FontAwesomeIcons.calendarCheck,
                label: 'Sessions',
              ),
              const FloatingNavItem(
                icon: FontAwesomeIcons.heart,
                selectedIcon: FontAwesomeIcons.solidHeart,
                label: 'Favoris',
              ),
              FloatingNavItem(
                icon: FontAwesomeIcons.comment,
                selectedIcon: FontAwesomeIcons.solidComment,
                label: 'Messages',
                badgeCount: unreadCount,
              ),
              const FloatingNavItem(
                icon: FontAwesomeIcons.gear,
                selectedIcon: FontAwesomeIcons.gears,
                label: 'Réglages',
              ),
            ],
          ),
        );
      },
    );
  }
}
