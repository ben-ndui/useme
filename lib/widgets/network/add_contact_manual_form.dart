import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Manual entry form for adding an off-platform contact.
class AddContactManualForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final VoidCallback onSubmit;

  const AddContactManualForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.noteController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: '${l10n.networkContactName} *',
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.emailHintGeneric,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phoneOptional,
            prefixIcon: const Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.networkNoteHint,
            prefixIcon: const Icon(Icons.note),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onSubmit,
            icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
            label: Text(l10n.addContact),
          ),
        ),
      ],
    );
  }
}
