import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/l10n/app_localizations.dart';

/// Écran de configuration de l'assistant IA pour un studio
class AISettingsScreen extends StatefulWidget {
  final String studioId;

  const AISettingsScreen({
    super.key,
    required this.studioId,
  });

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final ChatAssistantService _service = ChatAssistantService();
  StudioAISettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _service.getSettings(widget.studioId);
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.updateSettings(_settings!);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiAssistant),
        actions: [
          if (_settings != null)
            TextButton(
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? Center(child: Text(l10n.loadingError))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header avec icône
            _buildHeader(),
            const SizedBox(height: 24),

            // Activation
            _buildEnableSection(),
            const SizedBox(height: 24),

            // Mode de fonctionnement
            if (_settings!.enabled) ...[
              _buildModeSection(),
              const SizedBox(height: 24),

              // Ton de réponse
              _buildToneSection(),
              const SizedBox(height: 24),

              // Options avancées
              _buildAdvancedSection(),
              const SizedBox(height: 24),

              // FAQs personnalisées
              _buildFAQSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [UseMeTheme.accentColor, UseMeTheme.primaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UseMeTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.solidStar, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiAssistant,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aiAssistantDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableSection() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      child: SwitchListTile(
        title: Text(l10n.enableAIAssistant),
        subtitle: Text(
          _settings!.enabled
              ? l10n.aiHelpsRespond
              : l10n.aiDisabled,
        ),
        value: _settings!.enabled,
        onChanged: (value) {
          setState(() {
            _settings = _settings!.copyWith(enabled: value);
          });
        },
        secondary: FaIcon(
          _settings!.enabled
              ? FontAwesomeIcons.solidStar
              : FontAwesomeIcons.star,
          size: 18,
          color: _settings!.enabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildModeSection() {
    return _buildCard(
      title: AppLocalizations.of(context)!.operatingMode,
      child: Column(
        children: AIMode.values
            .where((m) => m != AIMode.off)
            .map((mode) => _buildModeOption(mode))
            .toList(),
      ),
    );
  }

  Widget _buildModeOption(AIMode mode) {
    final isSelected = _settings!.mode == mode;

    return ListTile(
      leading: Text(
        mode.icon,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(mode.displayName),
      subtitle: Text(
        mode.description,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      onTap: () {
        setState(() {
          _settings = _settings!.copyWith(mode: mode);
        });
      },
    );
  }

  Widget _buildToneSection() {
    final l10n = AppLocalizations.of(context)!;
    final tones = [
      ('professional', l10n.toneProfessional, l10n.toneProfessionalDesc),
      ('friendly', l10n.toneFriendly, l10n.toneFriendlyDesc),
      ('casual', l10n.toneCasual, l10n.toneCasualDesc),
    ];

    return _buildCard(
      title: l10n.responseTone,
      child: Column(
        children: tones.map((tone) {
          final isSelected = _settings!.tone == tone.$1;
          return ListTile(
            title: Text(tone.$2),
            subtitle: Text(tone.$3),
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            onTap: () {
              setState(() {
                _settings = _settings!.copyWith(tone: tone.$1);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.advancedOptions,
      child: Column(
        children: [
          SwitchListTile(
            title: Text(l10n.priceDiscussion),
            subtitle: Text(
              l10n.aiCanMentionDiscounts,
            ),
            value: _settings!.allowPriceDiscussion,
            onChanged: (value) {
              setState(() {
                _settings = _settings!.copyWith(allowPriceDiscussion: value);
              });
            },
          ),
          if (_settings!.mode == AIMode.autoReply) ...[
            const Divider(),
            ListTile(
              title: Text(l10n.autoReplyDelay),
              subtitle: Text(l10n.minutesCount(_settings!.autoReplyDelayMinutes)),
              trailing: DropdownButton<int>(
                value: _settings!.autoReplyDelayMinutes,
                items: [1, 2, 5, 10, 15, 30]
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text('$v min'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _settings = _settings!.copyWith(
                        autoReplyDelayMinutes: value,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.customFAQs,
      trailing: IconButton(
        icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
        onPressed: _showAddFAQDialog,
      ),
      child: Column(
        children: [
          if (_settings!.customFAQs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.customFAQsEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          else
            ..._settings!.customFAQs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(CustomFAQ faq) {
    return ListTile(
      title: Text(
        faq.question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        faq.answer,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => _removeFAQ(faq),
      ),
    );
  }

  void _showAddFAQDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addFAQ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: l10n.question,
                hintText: l10n.questionHint,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: l10n.answer,
                hintText: l10n.answerHint,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.isNotEmpty &&
                  answerController.text.isNotEmpty) {
                _addFAQ(CustomFAQ(
                  question: questionController.text,
                  answer: answerController.text,
                ));
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _addFAQ(CustomFAQ faq) async {
    setState(() {
      _settings = _settings!.copyWith(
        customFAQs: [..._settings!.customFAQs, faq],
      );
    });
    await _service.addFAQ(widget.studioId, faq);
  }

  Future<void> _removeFAQ(CustomFAQ faq) async {
    setState(() {
      _settings = _settings!.copyWith(
        customFAQs: _settings!.customFAQs.where((f) => f != faq).toList(),
      );
    });
    await _service.removeFAQ(widget.studioId, faq);
  }

  Widget _buildCard({
    String? title,
    Widget? trailing,
    required Widget child,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}
