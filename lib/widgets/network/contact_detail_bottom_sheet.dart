import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/core/blocs/blocs_exports.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/card_config.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/card/holo_card.dart';
import 'package:uzme/core/services/vcard_service.dart';
import 'package:uzme/widgets/network/contact_detail_header.dart';
import 'package:uzme/widgets/network/contact_invite_helper.dart';

/// Bottom sheet showing full contact details with actions.
/// For platform contacts, displays their HoloCard at the top.
class ContactDetailBottomSheet extends StatelessWidget {
  final UserContact contact;

  const ContactDetailBottomSheet({super.key, required this.contact});

  static void show(BuildContext context, UserContact contact) {
    final networkBloc = context.read<NetworkBloc>();
    final authBloc = context.read<AuthBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: networkBloc),
          BlocProvider.value(value: authBloc),
        ],
        child: ContactDetailBottomSheet(contact: contact),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: contact.isOnPlatform ? 0.75 : 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // HoloCard for platform contacts
            if (contact.isOnPlatform && contact.contactUserId != null)
              _ContactHoloCard(contactUserId: contact.contactUserId!),
            if (!contact.isOnPlatform) ContactDetailHeader(contact: contact),
            const SizedBox(height: 24),
            if (contact.note != null && contact.note!.isNotEmpty)
              _buildNote(theme, l10n),
            if (contact.tags.isNotEmpty) _buildTags(theme),
            _buildActions(context, l10n),
            const SizedBox(height: 8),
            _buildShareVCard(context, theme, l10n),
            const SizedBox(height: 8),
            _buildDeleteButton(context, theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.networkNote,
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(contact.note!, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: contact.tags
            .map((tag) => Chip(
                  label: Text(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        if (contact.contactEmail != null)
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.envelope, size: 18),
            title: Text(contact.contactEmail!),
            trailing: contact.isOnPlatform
                ? null
                : TextButton(
                    onPressed: () =>
                        ContactInviteHelper.sendEmailInvite(context, contact),
                    child: Text(l10n.networkInvite),
                  ),
            onTap: () =>
                ContactInviteHelper.launchEmail(contact.contactEmail!),
          ),
        if (contact.contactPhone != null)
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.phone, size: 18),
            title: Text(contact.contactPhone!),
            trailing: contact.isOnPlatform
                ? null
                : TextButton(
                    onPressed: () =>
                        ContactInviteHelper.sendSmsInvite(context, contact),
                    child: Text(l10n.networkInvite),
                  ),
            onTap: () =>
                ContactInviteHelper.launchPhone(contact.contactPhone!),
          ),
      ],
    );
  }

  Widget _buildShareVCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          final vcard = VCardService().fromContact(contact);
          VCardService().share(vcard, name: contact.contactName);
        },
        icon: FaIcon(FontAwesomeIcons.addressCard,
            size: 14, color: theme.colorScheme.primary),
        label: Text(l10n.shareVCard,
            style: TextStyle(color: theme.colorScheme.primary)),
      ),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          context
              .read<NetworkBloc>()
              .add(RemoveContactEvent(contactId: contact.id));
          Navigator.of(context).pop();
        },
        icon: FaIcon(FontAwesomeIcons.trash,
            size: 14, color: theme.colorScheme.error),
        label: Text(l10n.remove,
            style: TextStyle(color: theme.colorScheme.error)),
      ),
    );
  }
}

/// Fetches a platform user's data + card config and displays their HoloCard.
class _ContactHoloCard extends StatefulWidget {
  final String contactUserId;

  const _ContactHoloCard({required this.contactUserId});

  @override
  State<_ContactHoloCard> createState() => _ContactHoloCardState();
}

class _ContactHoloCardState extends State<_ContactHoloCard> {
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
          .doc(widget.contactUserId)
          .get();

      if (!mounted || doc.data() == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = AppUser.fromMap(doc.data()!, doc.id);
      final cardConfigData = doc.data()!['cardConfig'];
      final cardConfig = cardConfigData != null
          ? CardConfig.fromMap(cardConfigData as Map<String, dynamic>)
          : const CardConfig();

      setState(() {
        _user = user;
        _cardConfig = cardConfig;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HoloCard(user: _user!, cardConfig: _cardConfig),
    );
  }
}
