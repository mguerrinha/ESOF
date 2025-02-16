import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:spantry/pages/home_page.dart';
import 'package:spantry/pages/inventory/inventory_page.dart';
import 'package:spantry/pages/shopping_list/shopping_list_page.dart';
import 'package:spantry/pages/settings/profile.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 0;
  List<Widget> widgetOptions = <Widget>[
    const HomePage(),
    const InventoryPage(),
    const ShoppingListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(currentIndex),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.green,
            gap: 8,
            padding: const EdgeInsets.all(12),
            onTabChange: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(
                icon: Icons.kitchen,
                text: 'Pantry',
              ),
              GButton(
                icon: Icons.checklist,
                text: 'List',
              ),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
            selectedIndex: currentIndex,
          ),
        ),
      ),
    );
  }
}
