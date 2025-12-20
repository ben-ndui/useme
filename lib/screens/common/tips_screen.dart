import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/tip_item.dart';

/// Screen displaying tips and guides for app usage with smooth animations
class TipsScreen extends StatefulWidget {
  final String title;
  final List<TipSection> sections;

  const TipsScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final Set<String> _expandedTips = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: _buildHeader(theme),
          ),
          const SizedBox(height: 24),
          ...widget.sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return FadeInUp(
              delay: Duration(milliseconds: 100 + (index * 100)),
              duration: const Duration(milliseconds: 400),
              child: _buildSection(theme, section, index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Pulse(
            infinite: true,
            duration: const Duration(seconds: 2),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.lightbulb, color: Colors.white, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Decouvrez comment tirer le meilleur de Use Me',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, TipSection section, int sectionIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(section.icon, size: 16, color: section.color),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                section.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Tips cards with staggered animation
          ...section.tips.asMap().entries.map((entry) {
            final tipIndex = entry.key;
            final tip = entry.value;
            return SlideInRight(
              delay: Duration(milliseconds: 50 * tipIndex),
              duration: const Duration(milliseconds: 300),
              child: _buildTipCard(theme, tip, section.color, '${sectionIndex}_$tipIndex'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme, TipItem tip, Color accentColor, String tipKey) {
    final isExpanded = _expandedTips.contains(tipKey);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedTips.remove(tipKey);
          } else {
            _expandedTips.add(tipKey);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExpanded
              ? (tip.iconColor ?? accentColor).withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? (tip.iconColor ?? accentColor).withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (tip.iconColor ?? accentColor).withValues(alpha: isExpanded ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: FaIcon(
                      tip.icon,
                      size: 17,
                      color: tip.iconColor ?? accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            // Animated description
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14, left: 54),
                child: Text(
                  tip.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}
