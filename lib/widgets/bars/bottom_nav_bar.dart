// Imports necessary Flutter and project-specific packages
import 'package:flutter/material.dart';
import 'package:myapp/theme/app_pallete.dart';

// Stateless widget for the bottom navigation bar
class BottomNavBar extends StatelessWidget {
  final int selectedIndex; // Tracks the current selected tab
  final Function(int) onItemTapped; // Callback for tap events

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Container for styling the navigation bar
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24), // Rounded top-left corner
          topRight: Radius.circular(24), // Rounded top-right corner
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10, // Shadow for elevation effect
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex, // Highlights the current tab
          onTap: onItemTapped, // Calls callback when an item is tapped
          type: BottomNavigationBarType.fixed, // Ensures all items are visible
          backgroundColor: Colors.white, // Background color
          selectedItemColor: LightAppPallete.accentDark, // Color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
          showSelectedLabels: true, // Shows labels for selected items
          showUnselectedLabels: true, // Shows labels for unselected items
          items: const [
            // Navigation items
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Rechercher',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Créer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}