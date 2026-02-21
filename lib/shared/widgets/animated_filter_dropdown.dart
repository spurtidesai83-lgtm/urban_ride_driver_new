import 'package:flutter/material.dart';

/// A reusable dropdown widget that replicates the strict Figma animation specs:
/// - Open: Height 0 -> Full, Opacity 0 -> 1 using SizeTransition (ClipRect)
/// - Close: Reverse animation
/// - No Scale, No Slide, No Blur
class FigmaFilterDropdown extends StatefulWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final List<String> options;

  const FigmaFilterDropdown({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    this.options = const ['Today', 'This Month', 'This Year', 'All Time'],
  });

  @override
  State<FigmaFilterDropdown> createState() => _FigmaFilterDropdownState();
}

class _FigmaFilterDropdownState extends State<FigmaFilterDropdown> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Very slow: 1.5s total
    );

    // Curve: easeOutCubic per spec
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic, // Symmetric: Fast start, slow end on both Open and Close
    );

    // Opacity: 0 -> 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    // Size: Vertical Clip
    _sizeAnimation = curvedAnimation;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() => _isOpen = true);
  }

  void _closeDropdown() async {
    await _animationController.reverse();
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Width = icon width * 4 => 40 * 4 = 160.
    // Constrain to screen width minus padding (e.g. 20px each side)
    final dropdownWidth = (size.width * 4.0).clamp(150.0, screenWidth - 40.0);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background tap detector to close
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Dropdown Menu
          Positioned(
            width: dropdownWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // Anchor: Right align to button. 
              // offset.dx = buttonWidth (40) - dropdownWidth (e.g. 160) = -120.
              offset: Offset(size.width - dropdownWidth, size.height + 8), 
              child: Material(
                elevation: 4, 
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SizeTransition(
                  sizeFactor: _sizeAnimation,
                  axisAlignment: -1.0, // Pivot at TOP (-1.0). Grows downwards.
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                      ),
                      clipBehavior: Clip.hardEdge, 
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isSelected = widget.activeFilter == option;

                          // Staggered Animation for each item
                          // Start a bit after the container starts opening
                          final double start = 0.2 + (index * 0.15); 
                          final double end = start + 0.4;
                          
                          // Clamp to 1.0 just in case
                          final itemCurve = CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              start.clamp(0.0, 1.0), 
                              end.clamp(0.0, 1.0), 
                              curve: Curves.easeOut,
                            ),
                          );

                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.2), // Slide down slightly
                              end: Offset.zero,
                            ).animate(itemCurve),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(itemCurve),
                              child: InkWell(
                                onTap: () {
                                  widget.onFilterChanged(option);
                                  _closeDropdown();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: isSelected ? const Color(0xFFFFC200).withValues(alpha: 0.1) : Colors.transparent, // Light Yellow for selected
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFE6AE00) : Colors.black, // Darker yellow/gold text for readability
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB), // Light Grey background
            shape: BoxShape.circle,   // Circular shape
          ),
          child: const Center(
            child: Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: Colors.black, // Stark Black icon
            ),
          ),
        ),
      ),
    );
  }
}

