import 'package:flutter/material.dart';

/// A single tip/guide item
class TipItem {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;

  const TipItem({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });
}

/// A section containing multiple tips
class TipSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<TipItem> tips;

  const TipSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.tips,
  });
}
