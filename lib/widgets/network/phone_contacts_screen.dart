import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/core/services/network_service.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/common/permission_dialog.dart';
import 'package:uzme/widgets/network/phone_contact_tile.dart';
import 'package:uzme/widgets/network/phone_contacts_banner.dart';

/// Screen to import contacts from the phone's address book.
class PhoneContactsScreen extends StatefulWidget {
  const PhoneContactsScreen({super.key});

  @override
  State<PhoneContactsScreen> createState() => _PhoneContactsScreenState();
}

class _PhoneContactsScreenState extends State<PhoneContactsScreen> {
  final _networkService = NetworkService();
  List<PhoneContactItem> _contacts = [];
  final Set<int> _selected = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final granted = await PermissionDialog.requestPermission(
      context,
      type: AppPermissionType.contacts,
    );

    if (!granted) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final phoneContacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    final platformUsers = await _matchPlatformUsers(phoneContacts);

    final items = phoneContacts.map((c) {
      final email = c.emails.isNotEmpty ? c.emails.first.address : null;
      final phone = c.phones.isNotEmpty ? c.phones.first.number : null;
      final matchedUser =
          email != null ? platformUsers[email.toLowerCase()] : null;

      return PhoneContactItem(
        contact: c,
        email: email,
        phone: phone,
        platformUser: matchedUser,
        isOnPlatform: matchedUser != null,
      );
    }).toList();

    items.sort((a, b) {
      if (a.isOnPlatform != b.isOnPlatform) return a.isOnPlatform ? -1 : 1;
      return a.contact.displayName.compareTo(b.contact.displayName);
    });

    if (mounted) {
      setState(() {
        _contacts = items;
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _matchPlatformUsers(
    List<Contact> phoneContacts,
  ) async {
    final platformUsers = <String, dynamic>{};
    for (final c in phoneContacts) {
      for (final e in c.emails) {
        final email = e.address.toLowerCase();
        if (email.length >= 3 && !platformUsers.containsKey(email)) {
          final results = await _networkService.searchUsers(email);
          for (final user in results) {
            platformUsers[user.email.toLowerCase()] = user;
          }
        }
      }
    }
    return platformUsers;
  }

  List<PhoneContactItem> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    final q = _searchQuery.toLowerCase();
    return _contacts.where((c) {
      return c.contact.displayName.toLowerCase().contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  Future<void> _importSelected() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticatedState) return;

    final bloc = context.read<NetworkBloc>();
    final userId = authState.user.uid;

    for (final index in _selected) {
      final item = _filteredContacts[index];
      if (item.isOnPlatform && item.platformUser != null) {
        bloc.add(AddPlatformContactEvent(
          userId: userId,
          contact: item.platformUser!,
          category: ContactCategory.other,
        ));
      } else {
        bloc.add(AddOffPlatformContactEvent(
          userId: userId,
          name: item.contact.displayName,
          email: item.email,
          phone: item.phone,
          category: ContactCategory.other,
        ));
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPlatformCount = _contacts.where((c) => c.isOnPlatform).length;
    final filtered = _filteredContacts;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importContacts),
        actions: [
          if (_selected.isNotEmpty)
            TextButton.icon(
              onPressed: _importSelected,
              icon: const FaIcon(FontAwesomeIcons.check, size: 14),
              label: Text(l10n.importCount(_selected.length)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (onPlatformCount > 0)
                  PhoneContactsBanner(count: onPlatformCount),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchContact,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text(l10n.noResult))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => PhoneContactTile(
                            item: filtered[i],
                            isSelected: _selected.contains(i),
                            onTap: () => _toggleSelect(i),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
