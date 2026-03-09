import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/user_contact.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/network/add_contact_bottom_sheet.dart';
import 'package:useme/widgets/network/contact_card.dart';
import 'package:useme/widgets/network/contact_detail_bottom_sheet.dart';

/// Screen showing the user's professional network.
class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myNetwork),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 18),
            onPressed: () => AddContactBottomSheet.show(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: BlocConsumer<NetworkBloc, NetworkState>(
        listenWhen: (prev, curr) =>
            curr.errorMessage != null || curr.successMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.contacts.isEmpty) {
            return _buildEmptyState(context, theme, l10n);
          }

          return _buildContactList(context, state, theme, l10n);
        },
      ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.userGroup,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.networkEmpty,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.networkEmptyDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => AddContactBottomSheet.show(context),
              icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
              label: Text(l10n.addContact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(
    BuildContext context,
    NetworkState state,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final categories = ContactCategory.values;

    return DefaultTabController(
      length: categories.length + 1,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: '${l10n.all} (${state.contacts.length})'),
              ...categories.map((c) {
                final count = state.getByCategory(c).length;
                return Tab(text: '${_categoryLabel(c, l10n)} ($count)');
              }),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildList(context, state.contacts),
                ...categories.map(
                  (c) => _buildList(context, state.getByCategory(c)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<UserContact> contacts) {
    if (contacts.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noResult,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: contacts.length,
      itemBuilder: (context, index) => ContactCard(
        contact: contacts[index],
        onTap: () =>
            ContactDetailBottomSheet.show(context, contacts[index]),
      ),
    );
  }

  String _categoryLabel(ContactCategory category, AppLocalizations l10n) {
    switch (category) {
      case ContactCategory.artist:
        return l10n.artistsLabel;
      case ContactCategory.engineer:
        return l10n.engineersLabel;
      case ContactCategory.producer:
        return l10n.networkProducer;
      case ContactCategory.studio:
        return l10n.studiosLabel;
      case ContactCategory.other:
        return l10n.networkOther;
    }
  }
}
