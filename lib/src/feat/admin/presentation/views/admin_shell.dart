import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/admin/presentation/views/pages/admin_dashboard_page.dart';
import 'package:mabar_slurd/src/feat/admin/presentation/views/pages/admin_venues_page.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/profile_page.dart';

class AdminShell extends StatefulWidget {
  final int initialIndex;

  const AdminShell({super.key, this.initialIndex = 0});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    AdminVenuesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: CustomColors.mabarBgDark,
          elevation: 0,
          selectedItemColor: CustomColors.mabarPurpleLight,
          unselectedItemColor: CustomColors.mabarTextTertiary,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined),
              activeIcon: Icon(Icons.inbox),
              label: "Booking",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: "Venue Saya",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
