import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Screen size breakpoints for responsive design
class ScreenBreakpoints {
  /// Mobile devices (phones)
  static const double mobile = 600;
  
  /// Tablet devices
  static const double tablet = 900;
  
  /// Desktop/PC devices
  static const double desktop = 1200;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Platform type enum
enum PlatformType {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
  fuchsia,
  unknown,
}

/// Responsive layout helper class
class ResponsiveLayout {
  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < ScreenBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ScreenBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }
  
  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }
  
  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }
  
  /// Check if current device is tablet or desktop (side-by-side layout)
  static bool isTabletOrDesktop(BuildContext context) {
    return !isMobile(context);
  }
  
  /// Get current platform type
  static PlatformType getPlatformType() {
    if (kIsWeb) {
      return PlatformType.web;
    }
    
    try {
      if (Platform.isAndroid) return PlatformType.android;
      if (Platform.isIOS) return PlatformType.ios;
      if (Platform.isWindows) return PlatformType.windows;
      if (Platform.isMacOS) return PlatformType.macos;
      if (Platform.isLinux) return PlatformType.linux;
      if (Platform.isFuchsia) return PlatformType.fuchsia;
    } catch (e) {
      // Platform check might fail on web
      return PlatformType.web;
    }
    
    return PlatformType.unknown;
  }
  
  /// Check if platform is Windows
  static bool isWindows() {
    return getPlatformType() == PlatformType.windows;
  }
  
  /// Check if platform is mobile (Android or iOS)
  static bool isMobilePlatform() {
    final platform = getPlatformType();
    return platform == PlatformType.android || platform == PlatformType.ios;
  }
  
  /// Check if platform is desktop (Windows, macOS, Linux)
  static bool isDesktopPlatform() {
    final platform = getPlatformType();
    return platform == PlatformType.windows ||
        platform == PlatformType.macos ||
        platform == PlatformType.linux;
  }
  
  /// Get responsive value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
  
  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(
      responsiveValue<double>(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }
  
  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue<double>(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }
  
  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Check if screen is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  /// Get maximum content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 700;
      case DeviceType.desktop:
        return 1200;
    }
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Widget that adapts to screen size
class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const AdaptiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive container with max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final EdgeInsets? padding;
  
  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.centerContent = true,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveLayout.getMaxContentWidth(context);
    final defaultPadding = ResponsiveLayout.responsiveHorizontalPadding(context);
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding ?? defaultPadding,
        child: child,
      ),
    );
  }
}
