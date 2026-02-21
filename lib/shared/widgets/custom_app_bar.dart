import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Custom app bar widget used across all screens for consistency
/// 
/// Features:
/// - Menu icon on the left edge (aligned like home screen)
/// - Title beside menu icon
/// - Optional actions on the right (like toggle buttons, icons, etc.)
/// - Consistent padding and height across all screens
class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final Widget? actions;
  final double? titleFontSize;
  final bool includeStatusBarPadding;
  final bool showLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.actions,
    this.titleFontSize,
    this.includeStatusBarPadding = true,
    this.showLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: includeStatusBarPadding
          ? EdgeInsets.only(top: MediaQuery.of(context).padding.top)
          : EdgeInsets.zero,
      child: Container(
        padding: ResponsiveUtils.customPadding(
          context,
          left: 8,
          top: 8,
          right: 20,
          bottom: 8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            if (showLeading) ...[
              GestureDetector(
                onTap: onMenuTap ?? () {
                  Scaffold.of(context).openDrawer();
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.transparent,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: ResponsiveUtils.iconSize(context, 24),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.padding(context, 4)),
            ] else ...[
              SizedBox(width: ResponsiveUtils.padding(context, 12)),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: ResponsiveUtils.fontSize(
                    context,
                    titleFontSize ?? 20,
                  ),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actions != null) ...[
              SizedBox(width: ResponsiveUtils.padding(context, 8)),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}
