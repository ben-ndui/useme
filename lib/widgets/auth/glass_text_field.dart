import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Text field that adapts to theme:
/// - Dark mode: glassmorphism with white-translucent background
/// - Light mode: solid surfaceContainerHigh with theme border/colors
class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12 * _glowAnimation.value)
                      : cs.primary.withValues(alpha: 0.12 * _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isDark
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: _buildFieldContainer(isDark, cs),
                    ),
                  )
                : _buildFieldContainer(isDark, cs),
          ),
        );
      },
    );
  }

  Widget _buildFieldContainer(bool isDark, ColorScheme cs) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: _isFocused ? 0.25 : 0.15),
                  Colors.white.withValues(alpha: _isFocused ? 0.15 : 0.08),
                ],
              )
            : null,
        color: isDark ? null : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? (_isFocused
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2))
              : (_isFocused ? cs.primary : cs.outlineVariant),
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: _buildTextField(isDark, cs),
    );
  }

  Widget _buildTextField(bool isDark, ColorScheme cs) {
    final textColor = isDark ? Colors.white : cs.onSurface;
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : cs.onSurface.withValues(alpha: 0.45);
    final iconColor = isDark
        ? (_isFocused
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.6))
        : (_isFocused ? cs.primary : cs.onSurfaceVariant);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      cursorColor: isDark ? Colors.white : cs.primary,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.7) : cs.onSurfaceVariant,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white : cs.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: FaIcon(widget.prefixIcon, size: 18, color: iconColor),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.suffixIcon,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.prefixIcon != null ? 0 : 20,
          vertical: 18,
        ),
        errorStyle: TextStyle(
          color: isDark ? Colors.orange.shade200 : cs.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Password text field with toggle visibility
class GlassPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const GlassPasswordField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<GlassPasswordField> createState() => _GlassPasswordFieldState();
}

class _GlassPasswordFieldState extends State<GlassPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : cs.onSurfaceVariant;

    return GlassTextField(
      controller: widget.controller,
      hint: widget.hint,
      label: widget.label,
      prefixIcon: FontAwesomeIcons.lock,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: FaIcon(
          _obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }
}

/// Primary action button — white gradient in dark, primary color in light
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    // Colors adapt to theme
    final Color bgColor;
    final Color fgColor;
    final Gradient? gradient;
    final List<BoxShadow>? shadows;
    final Border? border;

    if (widget.isPrimary) {
      if (isDark) {
        // Dark: white button with black text (contrasts on dark bg)
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F0F0)],
        );
        bgColor = Colors.transparent;
        fgColor = Colors.black87;
        shadows = [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ];
        border = null;
      } else {
        // Light: primary color button with onPrimary text
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.85)],
        );
        bgColor = Colors.transparent;
        fgColor = cs.onPrimary;
        shadows = [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ];
        border = null;
      }
    } else {
      // Secondary button
      gradient = null;
      if (isDark) {
        bgColor = Colors.white.withValues(alpha: 0.15);
        fgColor = Colors.white;
        shadows = null;
        border = Border.all(color: Colors.white.withValues(alpha: 0.3));
      } else {
        bgColor = cs.surfaceContainerHigh;
        fgColor = cs.onSurface;
        shadows = null;
        border = Border.all(color: cs.outlineVariant);
      }
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? bgColor : null,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: shadows,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fgColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        FaIcon(widget.icon, size: 16, color: fgColor),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Social login button — glass in dark, surface card in light
class GlassSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const GlassSocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : cs.surfaceContainerHigh;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : cs.outlineVariant;
    final fgColor = isDark ? Colors.white : cs.onSurface;

    final child = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        splashColor: cs.onSurface.withValues(alpha: 0.08),
        highlightColor: cs.onSurface.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: fgColor),
                )
              else
                FaIcon(icon, size: 20, color: fgColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isDark) return ClipRRect(borderRadius: BorderRadius.circular(14), child: child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: child,
      ),
    );
  }
}
