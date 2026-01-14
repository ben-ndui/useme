import 'package:flutter/material.dart';
import 'package:useme/config/useme_theme.dart';

/// Collapsible draggable sheet widget - adapted from Viba
class SmoothDraggableWidget extends StatefulWidget {
  const SmoothDraggableWidget({
    super.key,
    required this.bodyContent,
    this.floatButtons = const [],
    this.maxSize = 1,
    this.minSize = 0.12,
    this.initial = 0.5,
    this.threshold = 0.6,
    this.color1,
    this.color2,
    this.bottomPadding = 20,
    this.floatingBottomPadding = 40,
  });

  final Widget bodyContent;
  final List<Widget> floatButtons;
  final double maxSize;
  final double minSize;
  final double initial;
  final double threshold;
  final Color? color1;
  final Color? color2;
  final double bottomPadding;
  final double floatingBottomPadding;

  @override
  State<SmoothDraggableWidget> createState() => _SmoothDraggableWidgetState();
}

class _SmoothDraggableWidgetState extends State<SmoothDraggableWidget> {
  DraggableScrollableController controller = DraggableScrollableController();
  final ValueNotifier<bool> showButtons = ValueNotifier(false);
  final ValueNotifier<bool> showDragHandle = ValueNotifier(true);
  final ValueNotifier<double> safeAreaPadding = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    controller.addListener(_onSheetScroll);
  }

  void _onSheetScroll() {
    final normalizedSize =
        (controller.size - widget.minSize) / (widget.maxSize - widget.minSize);

    // Update floating action buttons visibility
    if (controller.size <= widget.minSize) {
      if (showButtons.value != false) showButtons.value = false;
    } else if (normalizedSize > widget.threshold) {
      if (showButtons.value != true) showButtons.value = true;
    }

    // Handle drag handle visibility
    final shouldShowDragHandle = controller.size <= widget.maxSize * 0.9;
    if (showDragHandle.value != shouldShowDragHandle) {
      showDragHandle.value = shouldShowDragHandle;
    }

    // SafeArea padding management
    final safePadding = MediaQuery.of(context).padding.top;
    final targetPadding =
        controller.size >= widget.maxSize * 0.99 ? safePadding : 0;
    if (safeAreaPadding.value != targetPadding) {
      safeAreaPadding.value = targetPadding.toDouble();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    showButtons.dispose();
    showDragHandle.dispose();
    safeAreaPadding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme colors by default
    final defaultColor1 = widget.color1 ?? UseMeTheme.primaryColor;
    final defaultColor2 = widget.color2 ?? UseMeTheme.secondaryColor;

    return DraggableScrollableSheet(
      initialChildSize: widget.initial,
      minChildSize: widget.minSize,
      maxChildSize: widget.maxSize,
      controller: controller,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: _SmoothBackground(
            color1: defaultColor1,
            color2: defaultColor2,
            child: Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildDragHandle()),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        ValueListenableBuilder<double>(
                          valueListenable: safeAreaPadding,
                          builder: (context, padding, child) {
                            return AnimatedPadding(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.only(
                                top: padding,
                                bottom: widget.bottomPadding,
                              ),
                              child: widget.bodyContent,
                            );
                          },
                        ),
                      ]),
                    ),
                  ],
                ),
                if (widget.floatButtons.isNotEmpty) _buildFloatButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return ValueListenableBuilder<bool>(
      valueListenable: showDragHandle,
      builder: (context, isVisible, child) {
        return AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatButtons() {
    // Account for bottom safe area (nav bar, gesture bar, etc.)
    final bottomSafeArea = MediaQuery.of(context).viewPadding.bottom;

    return ValueListenableBuilder<bool>(
      valueListenable: showButtons,
      builder: (context, isVisible, child) {
        return Positioned(
          right: 20,
          bottom: widget.floatingBottomPadding + bottomSafeArea,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: isVisible
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: widget.floatButtons
                        .map((btn) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: btn,
                            ))
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Simple background container with gradient
class _SmoothBackground extends StatelessWidget {
  final Widget child;
  final Color color1;
  final Color color2;

  const _SmoothBackground({
    required this.child,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }
}
