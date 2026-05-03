import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Search section for finding platform users to add as contacts.
class AddContactSearch extends StatelessWidget {
  final TextEditingController searchController;
  final Function(AppUser) onUserSelected;
  final VoidCallback onSwitchToManual;

  const AddContactSearch({
    super.key,
    required this.searchController,
    required this.onUserSelected,
    required this.onSwitchToManual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: (query) {
            context
                .read<NetworkBloc>()
                .add(SearchUsersEvent(query: query));
          },
          decoration: InputDecoration(
            hintText: l10n.searchByNameOrEmail,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<NetworkBloc, NetworkState>(
          buildWhen: (prev, curr) =>
              prev.searchResults != curr.searchResults ||
              prev.isSearching != curr.isSearching,
          builder: (context, state) {
            if (state.isSearching) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (searchController.text.length < 2) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    l10n.typeAtLeastTwoChars,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
              );
            }

            if (state.searchResults.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(l10n.noResult,
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onSwitchToManual,
                      child: Text(l10n.networkAddManually),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: state.searchResults
                  .map((user) => _buildUserTile(theme, user))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserTile(ThemeData theme, AppUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? FaIcon(FontAwesomeIcons.user,
                  size: 16, color: theme.colorScheme.outline)
              : null,
        ),
        title: Text(
          user.displayName ?? user.name ?? user.email,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.email),
        trailing: IconButton(
          icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
          onPressed: () => onUserSelected(user),
        ),
      ),
    );
  }
}
