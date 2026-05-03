import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/card_config.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/card/holo_card.dart';
import 'package:uzme/widgets/network/add_contact_bottom_sheet.dart';
import 'package:uzme/widgets/network/contact_card.dart';
import 'package:uzme/widgets/network/contact_detail_bottom_sheet.dart';

/// Screen showing the user's professional network.
/// Supports list view (default) and card grid view toggle.
class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  bool _isCardView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myNetwork),
        actions: [
          IconButton(
            icon: FaIcon(
              _isCardView
                  ? FontAwesomeIcons.list
                  : FontAwesomeIcons.grip,
              size: 18,
            ),
            onPressed: () => setState(() => _isCardView = !_isCardView),
            tooltip: _isCardView ? l10n.listView : l10n.cardView,
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.userPlus, size: 18),
            onPressed: () => AddContactBottomSheet.show(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: Responsive.maxContentWidth),
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
            Text(l10n.networkEmpty, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.networkEmptyDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
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
                _isCardView
                    ? _buildCardGrid(context, state.contacts)
                    : _buildList(context, state.contacts),
                ...categories.map((c) {
                  final filtered = state.getByCategory(c);
                  return _isCardView
                      ? _buildCardGrid(context, filtered)
                      : _buildList(context, filtered);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<UserContact> contacts) {
    if (contacts.isEmpty) return _buildEmptyTab(context);

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

  Widget _buildCardGrid(BuildContext context, List<UserContact> contacts) {
    final platformContacts =
        contacts.where((c) => c.isOnPlatform && c.contactUserId != null);
    final offPlatform =
        contacts.where((c) => !c.isOnPlatform || c.contactUserId == null);

    if (contacts.isEmpty) return _buildEmptyTab(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Platform contacts as mini HoloCards
        ...platformContacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () =>
                    ContactDetailBottomSheet.show(context, contact),
                child: _MiniContactCard(contact: contact),
              ),
            )),
        // Off-platform contacts as regular list items
        ...offPlatform.map((contact) => ContactCard(
              contact: contact,
              onTap: () =>
                  ContactDetailBottomSheet.show(context, contact),
            )),
      ],
    );
  }

  Widget _buildEmptyTab(BuildContext context) {
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

/// Loads user data from Firestore and displays a mini HoloCard.
class _MiniContactCard extends StatefulWidget {
  final UserContact contact;

  const _MiniContactCard({required this.contact});

  @override
  State<_MiniContactCard> createState() => _MiniContactCardState();
}

class _MiniContactCardState extends State<_MiniContactCard> {
  AppUser? _user;
  CardConfig? _cardConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.contact.contactUserId)
          .get();

      if (!mounted || doc.data() == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = AppUser.fromMap(doc.data()!, doc.id);
      final cardConfigData = doc.data()!['cardConfig'];
      final config = cardConfigData != null
          ? CardConfig.fromMap(cardConfigData as Map<String, dynamic>)
          : const CardConfig();

      setState(() {
        _user = user;
        _cardConfig = config;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AspectRatio(
        aspectRatio: 1.586,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_user == null) {
      return ContactCard(
        contact: widget.contact,
        onTap: () =>
            ContactDetailBottomSheet.show(context, widget.contact),
      );
    }

    return HoloCard(user: _user!, cardConfig: _cardConfig);
  }
}
