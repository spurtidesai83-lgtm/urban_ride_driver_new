import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Widget to display backend error messages when API calls fail
class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String? title;

  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.title = 'Failed to Load',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: ResponsiveUtils.width(context, 80),
              height: ResponsiveUtils.width(context, 80),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: ResponsiveUtils.iconSize(context, 40),
                color: Colors.red,
              ),
            ),

            SizedBox(height: ResponsiveUtils.padding(context, 24)),

            // Title
            Text(
              title!,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: ResponsiveUtils.padding(context, 12)),

            // Error Message
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: ResponsiveUtils.padding(context, 32)),

            // Retry Button (if callback provided)
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC200),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.padding(context, 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.borderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title = 'No Data Available',
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Icon
            Container(
              width: ResponsiveUtils.width(context, 80),
              height: ResponsiveUtils.width(context, 80),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.iconSize(context, 40),
                color: Colors.grey,
              ),
            ),

            SizedBox(height: ResponsiveUtils.padding(context, 24)),

            // Title
            Text(
              title!,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: ResponsiveUtils.padding(context, 12)),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
