import 'package:flutter/material.dart';
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/services_exports.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres sauvegardés')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
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
                  : const Text('Sauvegarder'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? const Center(child: Text('Erreur de chargement'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.blue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Assistant IA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Répondez automatiquement aux questions fréquentes '
            'et gagnez du temps',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableSection() {
    return _buildCard(
      child: SwitchListTile(
        title: const Text('Activer l\'assistant IA'),
        subtitle: Text(
          _settings!.enabled
              ? 'L\'IA aide à répondre aux messages'
              : 'L\'IA est désactivée',
        ),
        value: _settings!.enabled,
        onChanged: (value) {
          setState(() {
            _settings = _settings!.copyWith(enabled: value);
          });
        },
        secondary: Icon(
          _settings!.enabled ? Icons.smart_toy : Icons.smart_toy_outlined,
          color: _settings!.enabled ? Colors.purple : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildModeSection() {
    return _buildCard(
      title: 'Mode de fonctionnement',
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
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.purple)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {
        setState(() {
          _settings = _settings!.copyWith(mode: mode);
        });
      },
    );
  }

  Widget _buildToneSection() {
    final tones = [
      ('professional', 'Professionnel', 'Formel et courtois'),
      ('friendly', 'Amical', 'Chaleureux et accueillant'),
      ('casual', 'Décontracté', 'Relax mais respectueux'),
    ];

    return _buildCard(
      title: 'Ton des réponses',
      child: Column(
        children: tones.map((tone) {
          final isSelected = _settings!.tone == tone.$1;
          return ListTile(
            title: Text(tone.$2),
            subtitle: Text(tone.$3),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.purple)
                : const Icon(Icons.circle_outlined, color: Colors.grey),
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
    return _buildCard(
      title: 'Options avancées',
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Discussion de prix'),
            subtitle: const Text(
              'L\'IA peut mentionner les réductions possibles',
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
              title: const Text('Délai avant réponse auto'),
              subtitle: Text('${_settings!.autoReplyDelayMinutes} minutes'),
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
    return _buildCard(
      title: 'FAQs personnalisées',
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
        onPressed: _showAddFAQDialog,
      ),
      child: Column(
        children: [
          if (_settings!.customFAQs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Ajoutez des questions fréquentes pour que l\'IA '
                'puisse y répondre automatiquement',
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Ex: Quels sont vos horaires ?',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Réponse',
                hintText: 'Ex: Nous sommes ouverts du lundi au samedi...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
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
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _addFAQ(CustomFAQ faq) {
    setState(() {
      _settings = _settings!.copyWith(
        customFAQs: [..._settings!.customFAQs, faq],
      );
    });
  }

  void _removeFAQ(CustomFAQ faq) {
    setState(() {
      _settings = _settings!.copyWith(
        customFAQs: _settings!.customFAQs.where((f) => f != faq).toList(),
      );
    });
  }

  Widget _buildCard({
    String? title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
