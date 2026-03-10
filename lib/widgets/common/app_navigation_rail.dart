import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Navigation rail item configuration
class AppNavRailItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isMessages;
  final int badgeCount;

  const AppNavRailItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isMessages = false,
    this.badgeCount = 0,
  });
}

/// Shared NavigationRail for tablet/desktop layouts
class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavRailItem> items;

  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.primary,
        size: 20,
      ),
      unselectedIconTheme: IconThemeData(
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      selectedLabelTextStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Image.asset('assets/logo/appstore.png', width: 32, height: 32),
      ),
      destinations: items.map((item) {
        if (item.isMessages) return _buildMessagesDestination(item);
        if (item.badgeCount > 0) return _buildBadgeDestination(item);
        return NavigationRailDestination(
          icon: FaIcon(item.icon, size: 18),
          selectedIcon: FaIcon(item.selectedIcon, size: 18),
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  NavigationRailDestination _buildBadgeDestination(AppNavRailItem item) {
    return NavigationRailDestination(
      icon: Badge(
        isLabelVisible: item.badgeCount > 0,
        label: Text(
            item.badgeCount > 99 ? '99+' : item.badgeCount.toString()),
        child: FaIcon(item.icon, size: 18),
      ),
      selectedIcon: Badge(
        isLabelVisible: item.badgeCount > 0,
        label: Text(
            item.badgeCount > 99 ? '99+' : item.badgeCount.toString()),
        child: FaIcon(item.selectedIcon, size: 18),
      ),
      label: Text(item.label),
    );
  }

  NavigationRailDestination _buildMessagesDestination(AppNavRailItem item) {
    return NavigationRailDestination(
      icon: BlocBuilder<MessagingBloc, MessagingState>(
        buildWhen: (prev, curr) {
          final p =
              prev is ConversationsLoadedState ? prev.totalUnreadCount : 0;
          final c =
              curr is ConversationsLoadedState ? curr.totalUnreadCount : 0;
          return p != c;
        },
        builder: (context, state) {
          final count =
              state is ConversationsLoadedState ? state.totalUnreadCount : 0;
          return Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : count.toString()),
            child: FaIcon(item.icon, size: 18),
          );
        },
      ),
      selectedIcon: FaIcon(item.selectedIcon, size: 18),
      label: Text(item.label),
    );
  }
}
