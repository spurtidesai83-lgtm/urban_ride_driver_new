import 'package:flutter/material.dart';

class DraggableMapButton extends StatefulWidget {
  final VoidCallback onTap;

  const DraggableMapButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DraggableMapButton> createState() => _DraggableMapButtonState();
}

class _DraggableMapButtonState extends State<DraggableMapButton> {
  double? _topOffset;
  bool _isOnRight = true;
  bool _isDragging = false;

  final double _pillWidth = 48;
  final double _pillHeight = 44;

  double get _leftPosition {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_isOnRight) {
      return screenWidth - _pillWidth;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxTop = screenSize.height - _pillHeight - 100;
    const minTop = 16.0;

    _topOffset ??= 269;

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: _leftPosition,
      top: _topOffset!.clamp(minTop, maxTop),
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => _isDragging = true);
        },
        onPanUpdate: (details) {
          setState(() {
            _topOffset = (_topOffset! + details.delta.dy).clamp(minTop, maxTop);
            if (details.delta.dx > 3) _isOnRight = true;
            if (details.delta.dx < -3) _isOnRight = false;
          });
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
        },
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _pillWidth,
          height: _pillHeight,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            borderRadius: _isOnRight
                ? const BorderRadius.only(
                    topLeft: Radius.circular(9999),
                    bottomLeft: Radius.circular(9999),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(9999),
                    bottomRight: Radius.circular(9999),
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: Offset(_isOnRight ? -1 : 1, 2),
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: 3.14159, // -180 degrees
              child: const Icon(
                Icons.map_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
