import 'package:flutter/material.dart';

/// Responsive utilities for consistent scaling across all device sizes.
/// 
/// Usage in any screen:
/// ```dart
/// import 'package:urbandriver/shared/utils/responsive_utils.dart';
/// 
/// // For font sizes
/// fontSize: ResponsiveUtils.fontSize(context, 16),
/// 
/// // For padding/spacing
/// padding: ResponsiveUtils.padding(context, 20),
/// 
/// // For dimensions
/// width: ResponsiveUtils.width(context, 100),
/// ```
class ResponsiveUtils {
  // Screen size breakpoints
  static const double _smallScreenWidth = 375.0;  // iPhone SE
  static const double _mediumScreenWidth = 414.0; // iPhone 14 Pro Max
  static const double _largeScreenWidth = 768.0;  // iPad Mini
  
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Check if device is small screen (phone)
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < _mediumScreenWidth;
  }
  
  /// Check if device is medium screen (large phone)
  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= _mediumScreenWidth && 
           screenWidth(context) < _largeScreenWidth;
  }
  
  /// Check if device is large screen (tablet)
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= _largeScreenWidth;
  }
  
  /// Get responsive font size based on screen width
  /// 
  /// Returns exact base size for standard phones, scales only for very small or very large screens.
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    
    // Only scale down for very small screens to prevent overflow
    if (width < 360) {
      return baseSize * 0.92;
    }
    // Exact base size for all standard phones (360-768px)
    else if (width < _largeScreenWidth) {
      return baseSize;
    } 
    // Scale up for tablets
    else {
      final scaleFactor = (width / _mediumScreenWidth).clamp(1.0, 1.2);
      return baseSize * scaleFactor;
    }
  }
  
  /// Get responsive padding/spacing value
  /// 
  /// Returns exact base padding for standard phones, scales only for very small or very large screens.
  static double padding(BuildContext context, double basePadding) {
    final width = screenWidth(context);
    
    // Only scale down for very small screens to prevent overflow
    if (width < 360) {
      return basePadding * 0.88;
    }
    // Exact base padding for all standard phones (360-768px)
    else if (width < _largeScreenWidth) {
      return basePadding;
    }
    // Scale up for tablets
    else {
      final scaleFactor = (width / _mediumScreenWidth).clamp(1.0, 1.3);
      return basePadding * scaleFactor;
    }
  }
  
  /// Get responsive width value
  /// 
  /// Scales width values proportionally to screen size.
  static double width(BuildContext context, double baseWidth) {
    final screenW = screenWidth(context);
    final scaleFactor = screenW / _mediumScreenWidth;
    return baseWidth * scaleFactor;
  }
  
  /// Get responsive height value
  /// 
  /// Scales height values proportionally to screen size.
  static double height(BuildContext context, double baseHeight) {
    final screenH = screenHeight(context);
    // Use a reference height of 896 (iPhone 14 Pro Max)
    final scaleFactor = screenH / 896.0;
    return baseHeight * scaleFactor;
  }
  
  /// Get width as percentage of screen width
  /// 
  /// Example: `widthPercent(context, 0.8)` returns 80% of screen width
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * percent;
  }
  
  /// Get height as percentage of screen height
  /// 
  /// Example: `heightPercent(context, 0.5)` returns 50% of screen height
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * percent;
  }
  
  /// Get responsive EdgeInsets for padding
  /// 
  /// Convenience method for symmetric padding
  static EdgeInsets symmetricPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: padding(context, horizontal),
      vertical: padding(context, vertical),
    );
  }
  
  /// Get responsive EdgeInsets for all-around padding
  static EdgeInsets allPadding(BuildContext context, double value) {
    return EdgeInsets.all(padding(context, value));
  }
  
  /// Get responsive EdgeInsets with custom values
  static EdgeInsets customPadding(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      padding(context, left),
      padding(context, top),
      padding(context, right),
      padding(context, bottom),
    );
  }
  
  /// Get responsive icon size
  /// 
  /// Optimized scaling for icons to maintain clarity
  static double iconSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    
    if (width < _smallScreenWidth) {
      return baseSize * 0.9;
    } else if (width < _largeScreenWidth) {
      return baseSize;
    } else {
      // Icons don't need to scale as much on tablets
      return baseSize * 1.15;
    }
  }
  
  /// Get responsive border radius
  static double borderRadius(BuildContext context, double baseRadius) {
    return padding(context, baseRadius);
  }
  
  /// Get responsive value with custom scaling
  /// 
  /// For any numeric value that needs to scale with screen size
  static double scale(BuildContext context, double baseValue) {
    final width = screenWidth(context);
    final scaleFactor = width / _mediumScreenWidth;
    return baseValue * scaleFactor;
  }
}
