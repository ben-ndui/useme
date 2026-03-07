import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/pro_profile.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Champs du formulaire profil pro.
class ProProfileFormFields extends StatelessWidget {
  final TextEditingController displayNameController;
  final TextEditingController bioController;
  final TextEditingController hourlyRateController;
  final TextEditingController cityController;
  final TextEditingController websiteController;
  final TextEditingController phoneController;

  final List<String> specialties;
  final List<String> instruments;
  final List<String> genres;
  final List<String> daws;
  final bool remote;
  final bool isAvailable;
  final List<ProType> selectedTypes;

  final ValueChanged<List<String>> onSpecialtiesChanged;
  final ValueChanged<List<String>> onInstrumentsChanged;
  final ValueChanged<List<String>> onGenresChanged;
  final ValueChanged<List<String>> onDawsChanged;
  final ValueChanged<bool> onRemoteChanged;
  final ValueChanged<bool> onAvailabilityChanged;

  const ProProfileFormFields({
    super.key,
    required this.displayNameController,
    required this.bioController,
    required this.hourlyRateController,
    required this.cityController,
    required this.websiteController,
    required this.phoneController,
    required this.specialties,
    required this.instruments,
    required this.genres,
    required this.daws,
    required this.remote,
    required this.isAvailable,
    required this.selectedTypes,
    required this.onSpecialtiesChanged,
    required this.onInstrumentsChanged,
    required this.onGenresChanged,
    required this.onDawsChanged,
    required this.onRemoteChanged,
    required this.onAvailabilityChanged,
  });

  bool get _showInstruments =>
      selectedTypes.contains(ProType.musician) ||
      selectedTypes.contains(ProType.composer);

  bool get _showDaws =>
      selectedTypes.contains(ProType.soundEngineer) ||
      selectedTypes.contains(ProType.producer);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom pro
        TextFormField(
          controller: displayNameController,
          decoration: InputDecoration(
            labelText: l10n.proProfileDisplayName,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.requiredField : null,
        ),
        const SizedBox(height: 16),

        // Bio
        TextFormField(
          controller: bioController,
          decoration: InputDecoration(
            labelText: l10n.proProfileBio,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          maxLength: 300,
        ),
        const SizedBox(height: 8),

        // Tarif + Ville (row)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: hourlyRateController,
                decoration: InputDecoration(
                  labelText: l10n.proProfileRate,
                  prefixIcon:
                      const FaIcon(FontAwesomeIcons.euroSign, size: 16),
                  suffixText: '/h',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: l10n.proProfileCity,
                  prefixIcon: const Icon(Icons.location_city),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tags : Spécialités
        _TagField(
          label: l10n.proProfileSpecialties,
          hint: l10n.proProfileSpecialtiesHint,
          icon: FontAwesomeIcons.star,
          values: specialties,
          onChanged: onSpecialtiesChanged,
        ),
        const SizedBox(height: 16),

        // Tags : Genres
        _TagField(
          label: l10n.proProfileGenres,
          hint: l10n.proProfileGenresHint,
          icon: FontAwesomeIcons.music,
          values: genres,
          onChanged: onGenresChanged,
        ),

        // Tags : Instruments (conditionnel)
        if (_showInstruments) ...[
          const SizedBox(height: 16),
          _TagField(
            label: l10n.proProfileInstruments,
            hint: l10n.proProfileInstrumentsHint,
            icon: FontAwesomeIcons.guitar,
            values: instruments,
            onChanged: onInstrumentsChanged,
          ),
        ],

        // Tags : DAWs (conditionnel)
        if (_showDaws) ...[
          const SizedBox(height: 16),
          _TagField(
            label: l10n.proProfileDaws,
            hint: l10n.proProfileDawsHint,
            icon: FontAwesomeIcons.laptop,
            values: daws,
            onChanged: onDawsChanged,
          ),
        ],

        const SizedBox(height: 16),

        // Website + Phone
        TextFormField(
          controller: websiteController,
          decoration: InputDecoration(
            labelText: l10n.proProfileWebsite,
            prefixIcon: const Icon(Icons.language),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: l10n.proProfilePhone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Switches
        SwitchListTile.adaptive(
          title: Text(l10n.proProfileRemote),
          subtitle: Text(l10n.proProfileRemoteDesc),
          secondary: const FaIcon(FontAwesomeIcons.wifi, size: 18),
          value: remote,
          onChanged: onRemoteChanged,
        ),
        SwitchListTile.adaptive(
          title: Text(l10n.proProfileAvailable),
          subtitle: Text(l10n.proProfileAvailableDesc),
          secondary: const FaIcon(FontAwesomeIcons.circleCheck, size: 18),
          value: isAvailable,
          onChanged: onAvailabilityChanged,
        ),
      ],
    );
  }
}

/// Champ de tags (ajout/suppression dynamique).
class _TagField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const _TagField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.values,
    required this.onChanged,
  });

  @override
  State<_TagField> createState() => _TagFieldState();
}

class _TagFieldState extends State<_TagField> {
  final _controller = TextEditingController();

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isEmpty || widget.values.contains(tag)) return;
    widget.onChanged([...widget.values, tag]);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(widget.icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTag,
              icon: const Icon(Icons.add, size: 18),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        if (widget.values.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.values.map((tag) {
              return Chip(
                label: Text(tag, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  widget.onChanged(
                    widget.values.where((t) => t != tag).toList(),
                  );
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
