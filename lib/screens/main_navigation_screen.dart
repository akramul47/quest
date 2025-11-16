import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsive_layout.dart';
import 'home_screen.dart';
import 'habits_screen.dart';
import 'focus_screen.dart';
import 'quest_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HabitsScreen(),
    FocusScreen(),
    QuestScreen(),
  ];

  final List<NavigationItem> _navItems = const [
    NavigationItem(
      icon: Icons.check_circle_outline_rounded,
      activeIcon: Icons.check_circle,
      label: 'TO-DO',
    ),
    NavigationItem(
      icon: Icons.track_changes,
      activeIcon: Icons.track_changes,
      label: 'Habits',
    ),
    NavigationItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Focus',
    ),
    NavigationItem(
      icon: Icons.military_tech_outlined,
      activeIcon: Icons.military_tech,
      label: 'Quest',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildTabletDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF000000) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                return _buildBottomNavItem(
                  item: _navItems[index],
                  isSelected: _currentIndex == index,
                  onTap: () => setState(() => _currentIndex = index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                letterSpacing: 0.1,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          // This is where screen-specific headers will go
          // Each screen will provide its own header
          Expanded(
            child: Row(
              children: [
                // Side Navigation Rail
                _buildSideNavigation(),
                // Main Content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Container(
      width: isDesktop ? 220 : 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF000000) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Navigation Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
            itemCount: _navItems.length,
            itemBuilder: (context, index) {
              return _buildSideNavItem(
                item: _navItems[index],
                isSelected: _currentIndex == index,
                isExpanded: isDesktop,
                onTap: () => setState(() => _currentIndex = index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavItem({
    required NavigationItem item,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 0,
            vertical: isExpanded ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(isDark ? 0.12 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isExpanded
              ? Row(
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.grey.shade400 : const Color(0xFF1A1A1A)),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                    size: 24,
                  ),
                ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
