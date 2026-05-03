import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/blocs/blocs_exports.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/user_contact.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/network/add_contact_manual_form.dart';
import 'package:uzme/widgets/network/add_contact_search.dart';
import 'package:uzme/widgets/network/import_phone_button.dart';
import 'package:uzme/widgets/network/phone_contacts_screen.dart';

/// Bottom sheet for adding a contact (platform, manual, or phone import).
class AddContactBottomSheet extends StatefulWidget {
  const AddContactBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<NetworkBloc>()),
          BlocProvider.value(value: context.read<AuthBloc>()),
        ],
        child: const AddContactBottomSheet(),
      ),
    );
  }

  @override
  State<AddContactBottomSheet> createState() => _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends State<AddContactBottomSheet> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  ContactCategory _category = ContactCategory.artist;
  bool _isManualMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addPlatformContact(AppUser user) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<NetworkBloc>().add(AddPlatformContactEvent(
            userId: authState.user.uid,
            contact: user,
            category: _category,
          ));
      Navigator.of(context).pop();
    }
  }

  void _addManualContact() {
    if (_nameController.text.trim().isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.read<NetworkBloc>().add(AddOffPlatformContactEvent(
            userId: authState.user.uid,
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
            phone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            category: _category,
            note: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          ));
      Navigator.of(context).pop();
    }
  }

  void _openPhoneContacts() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<NetworkBloc>()),
            BlocProvider.value(value: context.read<AuthBloc>()),
          ],
          child: const PhoneContactsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.addContact,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ImportPhoneButton(onTap: _openPhoneContacts),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              _buildModeToggle(l10n),
              const SizedBox(height: 16),
              if (_isManualMode)
                AddContactManualForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  noteController: _noteController,
                  onSubmit: _addManualContact,
                )
              else
                AddContactSearch(
                  searchController: _searchController,
                  onUserSelected: _addPlatformContact,
                  onSwitchToManual: () =>
                      setState(() => _isManualMode = true),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      children: ContactCategory.values.map((c) {
        return ChoiceChip(
          label: Text(c.label),
          selected: c == _category,
          onSelected: (_) => setState(() => _category = c),
        );
      }).toList(),
    );
  }

  Widget _buildModeToggle(AppLocalizations l10n) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 14),
          label: Text(l10n.search),
        ),
        ButtonSegment(
          value: true,
          icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 14),
          label: Text(l10n.networkManualAdd),
        ),
      ],
      selected: {_isManualMode},
      onSelectionChanged: (v) => setState(() => _isManualMode = v.first),
    );
  }
}
